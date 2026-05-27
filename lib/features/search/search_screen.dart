import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/audio/audio_provider.dart';
import '../../services/innertube/innertube_models.dart';
import '../../services/youtube_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = SearchController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String q) {
    final trimmed = q.trim();
    if (trimmed == _query) return;
    setState(() => _query = trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Search', style: tt.headlineMedium),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                controller: _controller,
                hintText: 'Songs, artists, albums',
                leading: const Icon(Icons.search_rounded, size: 20),
                trailing: _query.isNotEmpty
                    ? [
                        IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        )
                      ]
                    : null,
                onSubmitted: _submit,
                onChanged: (v) {
                  if (v.isEmpty) setState(() => _query = '');
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.isEmpty
                  ? _CategoryGrid()
                  : _SearchResults(query: _query),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live search results
// ---------------------------------------------------------------------------

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider(query));

    return results.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) => Center(
        child: Text('Search failed',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded,
                    size: 48, color: Colors.white24),
                const SizedBox(height: 12),
                Text('No results for "$query"',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: items.length,
          itemBuilder: (context, i) => _SearchTile(item: items[i]),
        );
      },
    );
  }
}

class _SearchTile extends ConsumerWidget {
  const _SearchTile({required this.item});
  final SearchItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final subtitle = [item.artist, item.album]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: AppTheme.artworkRadius,
        child: item.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: item.thumbnailUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _ArtPlaceholder(cs: cs),
              )
            : _ArtPlaceholder(cs: cs),
      ),
      title: Text(item.title,
          style: tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle,
              style: tt.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis)
          : null,
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert_rounded,
            size: 18, color: Colors.white38),
      ),
      onTap: () {
        if (item.videoId != null) {
          final song = item.toSong();
          ref.read(playerProvider.notifier).playSong(song);
          context.openPlayer();
        }
      },
    );
  }
}

class _ArtPlaceholder extends StatelessWidget {
  const _ArtPlaceholder({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        color: cs.surfaceContainer,
        child: Icon(Icons.music_note_rounded, size: 22, color: Colors.white24),
      );
}

// ---------------------------------------------------------------------------
// Browse categories (shown before a query is typed)
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final _categories = const [
    _Category('New releases', Icons.new_releases_outlined, Color(0xFF7C3AED)),
    _Category('Charts', Icons.bar_chart_rounded, Color(0xFF0EA5E9)),
    _Category('Trending', Icons.trending_up_rounded, Color(0xFFED5564)),
    _Category('Moods', Icons.mood_rounded, Color(0xFF10B981)),
    _Category('Hip-Hop', Icons.headphones_rounded, Color(0xFFF59E0B)),
    _Category('Electronic', Icons.electrical_services_rounded, Color(0xFF6366F1)),
    _Category('Pop', Icons.star_outline_rounded, Color(0xFFEC4899)),
    _Category('Rock', Icons.music_note_rounded, Color(0xFF78716C)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) => _CategoryCard(category: _categories[i]),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.icon, this.color);
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final _Category category;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color.withValues(alpha: 0.15),
      borderRadius: AppTheme.cardRadius,
      child: InkWell(
        onTap: () {},
        borderRadius: AppTheme.cardRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(category.icon, color: category.color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
