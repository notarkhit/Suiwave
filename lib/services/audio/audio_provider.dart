import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../data/models/song.dart';
import '../innertube/innertube_client.dart';

// ---------------------------------------------------------------------------
// Player state model
// ---------------------------------------------------------------------------

enum PlayerRepeatMode { off, one, all }

class PlayerState {
  final Song? currentTrack;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;
  final PlayerRepeatMode repeatMode;
  final bool shuffleEnabled;
  final List<Song> queue;
  final int currentIndex;

  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.repeatMode = PlayerRepeatMode.off,
    this.shuffleEnabled = false,
    this.queue = const [],
    this.currentIndex = 0,
  });

  bool get hasTrack => currentTrack != null;

  PlayerState copyWith({
    Song? currentTrack,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    PlayerRepeatMode? repeatMode,
    bool? shuffleEnabled,
    List<Song>? queue,
    int? currentIndex,
    bool clearTrack = false,
  }) {
    return PlayerState(
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PlayerNotifier extends Notifier<PlayerState> {
  late Player _player;

  @override
  PlayerState build() {
    _player = Player(
      configuration: PlayerConfiguration(
        title: 'Suiwave',
        ready: () {
          // Disable MPV disk cache as soon as the player is initialized,
          // before any media is loaded, to prevent cache write crashes on Linux
          if (Platform.isLinux && _player.platform is NativePlayer) {
            final native = _player.platform as NativePlayer;
            native.setProperty('cache', 'no');
            native.setProperty('cache-on-disk', 'no');
          }
        },
      ),
    );

    _player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });
    _player.stream.buffering.listen((buffering) {
      state = state.copyWith(isBuffering: buffering);
    });
    _player.stream.position.listen((position) {
      state = state.copyWith(position: position);
    });
    _player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    ref.onDispose(() => _player.dispose());

    return const PlayerState();
  }

  Future<void> playSong(Song song) async {
    print('playSong: ${song.title} (${song.videoId})');
    state = state.copyWith(currentTrack: song, isBuffering: true);
    try {
      if (song.isLocal && song.localPath != null) {
        await _player.open(Media(song.localPath!));
        await _player.play();
      } else if (song.videoId != null) {
        // Resolve stream URL from InnerTube
        final response = await InnerTubeClient.player(song.videoId!);
        if (response.containsKey('error')) {
          print('InnerTube API Player Error: ${response['error']}');
        }

        final stream = InnerTubeParser.parseBestAudioStream(response);
        print('playSong stream parsed: ${stream?.url}');

        if (stream != null) {
          const vrUserAgent =
              'com.google.android.apps.youtube.vr.oculus/1.43.32 (Linux; U; Android 12; en_US; Quest 3; Build/SQ3A.220605.009.A1; Cronet/107.0.5284.2)';
          await _player.open(Media(
            stream.url,
            httpHeaders: {'User-Agent': vrUserAgent},
          ));
          await _player.play();
        } else {
          print('playSong: stream is null.');
          print('playabilityStatus: ${response['playabilityStatus']}');
        }
      }
    } catch (e, st) {
      print('playSong Exception: $e\n$st');
      state = state.copyWith(isBuffering: false);
    }
  }

  Future<void> togglePlayPause() async {
    await _player.playOrPause();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipNext() async {
    if (state.currentIndex < state.queue.length - 1) {
      final next = state.queue[state.currentIndex + 1];
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      await playSong(next);
    }
  }

  Future<void> skipPrevious() async {
    if (state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (state.currentIndex > 0) {
      final prev = state.queue[state.currentIndex - 1];
      state = state.copyWith(currentIndex: state.currentIndex - 1);
      await playSong(prev);
    }
  }

  void cycleRepeat() {
    final next = PlayerRepeatMode.values[
        (state.repeatMode.index + 1) % PlayerRepeatMode.values.length];
    state = state.copyWith(repeatMode: next);
  }

  void toggleShuffle() {
    state = state.copyWith(shuffleEnabled: !state.shuffleEnabled);
  }

  void setQueue(List<Song> songs, {int startIndex = 0}) {
    state = state.copyWith(queue: songs, currentIndex: startIndex);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);

final currentTrackProvider = Provider<Song?>((ref) {
  return ref.watch(playerProvider).currentTrack;
});

final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(playerProvider).isPlaying;
});
