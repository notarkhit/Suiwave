import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/song.dart';
import '../../services/audio/audio_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  bool _showLyrics = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider);
    final track = state.currentTrack;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _PlayerBackground(
        artUrl: track?.albumArtUrl,
        child: SafeArea(
          child: Column(
            children: [
              _PlayerTopBar(showLyrics: _showLyrics, onToggleLyrics: () {
                setState(() => _showLyrics = !_showLyrics);
              }),
              Expanded(
                child: _showLyrics
                    ? _LyricsPanel(track: track)
                    : _ArtworkPanel(track: track),
              ),
              _PlayerInfo(state: state),
              _PlayerSeekBar(state: state),
              _PlayerControls(state: state),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Background — blurred album art gradient
// ---------------------------------------------------------------------------

class _PlayerBackground extends StatelessWidget {
  const _PlayerBackground({required this.artUrl, required this.child});
  final String? artUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0D0D0D)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (artUrl != null)
            Opacity(
              opacity: 0.18,
              child: CachedNetworkImage(
                imageUrl: artUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          // Gradient overlay — stronger at bottom
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0D0D0D).withValues(alpha: 0.6),
                  const Color(0xFF0D0D0D),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _PlayerTopBar extends StatelessWidget {
  const _PlayerTopBar({
    required this.showLyrics,
    required this.onToggleLyrics,
  });

  final bool showLyrics;
  final VoidCallback onToggleLyrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            color: Colors.white,
          ),
          const Spacer(),
          IconButton(
            onPressed: onToggleLyrics,
            icon: Icon(
              Icons.lyrics_outlined,
              size: 22,
              color: showLyrics
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white60,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded,
                size: 22, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Artwork
// ---------------------------------------------------------------------------

class _ArtworkPanel extends StatelessWidget {
  const _ArtworkPanel({required this.track});
  final Song? track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: AppTheme.cardRadius,
            child: track?.albumArtUrl != null
                ? CachedNetworkImage(
                    imageUrl: track!.albumArtUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        _ArtworkPlaceholder(cs: Theme.of(context).colorScheme),
                  )
                : _ArtworkPlaceholder(
                    cs: Theme.of(context).colorScheme),
          ),
        ),
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainer,
      child: Icon(
        Icons.music_note_rounded,
        size: 80,
        color: Colors.white24,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lyrics panel (placeholder)
// ---------------------------------------------------------------------------

class _LyricsPanel extends StatelessWidget {
  const _LyricsPanel({required this.track});
  final Song? track;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lyrics_outlined, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text('Lyrics coming soon', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'LRCLib sync will be available in the next update',
            style: tt.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Track info
// ---------------------------------------------------------------------------

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({required this.state});
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final track = state.currentTrack;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track?.title ?? 'Not playing',
                  style: tt.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track?.displayArtist ?? '',
                  style: tt.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded,
                size: 24, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seek bar
// ---------------------------------------------------------------------------

class _PlayerSeekBar extends ConsumerWidget {
  const _PlayerSeekBar({required this.state});
  final PlayerState state;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = state.duration.inMilliseconds > 0
        ? state.position.inMilliseconds / state.duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (v) {
              final pos = Duration(
                milliseconds: (v * state.duration.inMilliseconds).round(),
              );
              ref.read(playerProvider.notifier).seekTo(pos);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_format(state.position),
                    style: Theme.of(context).textTheme.labelSmall),
                Text(_format(state.duration),
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Controls
// ---------------------------------------------------------------------------

class _PlayerControls extends ConsumerWidget {
  const _PlayerControls({required this.state});
  final PlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(playerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            onPressed: notifier.toggleShuffle,
            icon: Icon(
              Icons.shuffle_rounded,
              size: 22,
              color: state.shuffleEnabled ? cs.primary : Colors.white54,
            ),
          ),
          // Previous
          IconButton(
            onPressed: notifier.skipPrevious,
            icon: const Icon(Icons.skip_previous_rounded,
                size: 36, color: Colors.white),
          ),
          // Play / pause — main button, no capsule container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: IconButton(
              onPressed: notifier.togglePlayPause,
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
          ),
          // Next
          IconButton(
            onPressed: notifier.skipNext,
            icon: const Icon(Icons.skip_next_rounded,
                size: 36, color: Colors.white),
          ),
          // Repeat
          IconButton(
            onPressed: notifier.cycleRepeat,
            icon: Icon(
              state.repeatMode == PlayerRepeatMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              size: 22,
              color: state.repeatMode != PlayerRepeatMode.off
                  ? cs.primary
                  : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
