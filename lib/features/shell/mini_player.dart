import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/audio/audio_provider.dart';
import '../../core/router/app_router.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final track = state.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final progress = state.duration.inMilliseconds > 0
        ? state.position.inMilliseconds / state.duration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTap: () => context.openPlayer(),
      child: Container(
        color: cs.surfaceContainer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin progress line at top
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Artwork
                  ClipRRect(
                    borderRadius: AppTheme.artworkRadius,
                    child: track.albumArtUrl != null
                        ? CachedNetworkImage(
                            imageUrl: track.albumArtUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _ArtworkPlaceholder(size: 44, cs: cs),
                          )
                        : _ArtworkPlaceholder(size: 44, cs: cs),
                  ),
                  const SizedBox(width: 12),
                  // Title + artist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.displayArtist,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Controls
                  IconButton(
                    onPressed: () =>
                        ref.read(playerProvider.notifier).togglePlayPause(),
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () =>
                        ref.read(playerProvider.notifier).skipNext(),
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      size: 28,
                      color: Colors.white70,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder({required this.size, required this.cs});
  final double size;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: cs.surfaceContainerHigh,
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.5,
        color: Colors.white30,
      ),
    );
  }
}
