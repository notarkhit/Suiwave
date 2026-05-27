import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/audio/audio_provider.dart';
import '../../services/innertube/innertube_models.dart';
import '../../services/youtube_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(
              'Suiwave',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          feed.when(
            loading: () => const SliverToBoxAdapter(child: _HomeSkeleton()),
            error: (e, _) => SliverToBoxAdapter(
              child: _ErrorPlaceholder(onRetry: () => ref.invalidate(homeFeedProvider)),
            ),
            data: (sections) => SliverPadding(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _SectionRow(section: sections[i]),
                  childCount: sections.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Real section row with horizontal card strip
// ---------------------------------------------------------------------------

class _SectionRow extends ConsumerWidget {
  const _SectionRow({required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(section.title,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: section.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _ItemCard(item: section.items[i]),
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item});
  final YTItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        if (item.videoId != null) {
          final song = item.toSong();
          ref.read(playerProvider.notifier).playSong(song);
          context.openPlayer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Playing Albums/Playlists is coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: SizedBox(
        width: 148,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppTheme.artworkRadius,
              child: item.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.thumbnailUrl!,
                      width: 148,
                      height: 148,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _Placeholder(cs: cs),
                    )
                  : _Placeholder(cs: cs),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: tt.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.subtitle != null && item.subtitle!.isNotEmpty)
              Text(
                item.subtitle!,
                style: tt.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) => Container(
        width: 148,
        height: 148,
        color: cs.surfaceContainer,
        child: Icon(Icons.music_note_rounded,
            size: 36, color: Colors.white24),
      );
}

// ---------------------------------------------------------------------------
// Skeleton shimmer while loading
// ---------------------------------------------------------------------------

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: cs.surfaceContainer,
              highlightColor: cs.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 0, 12),
                child: Container(
                    width: 160,
                    height: 18,
                    decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(4))),
              ),
            ),
            SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: cs.surfaceContainer,
                  highlightColor: cs.surfaceContainerHigh,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 148,
                          height: 148,
                          decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: AppTheme.artworkRadius)),
                      const SizedBox(height: 8),
                      Container(
                          width: 110,
                          height: 12,
                          decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 4),
                      Container(
                          width: 80,
                          height: 10,
                          decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text('Could not load feed', style: tt.titleMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Check your internet connection',
              style: tt.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
