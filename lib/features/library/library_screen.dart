import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text('Library', style: tt.headlineMedium),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 24),
                ),
              ],
              bottom: TabBar(
                tabs: const [
                  Tab(text: 'Playlists'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Artists'),
                ],
                labelStyle: tt.labelLarge,
                unselectedLabelStyle: tt.labelMedium?.copyWith(
                  color: Colors.white38,
                ),
                labelColor: cs.primary,
                unselectedLabelColor: Colors.white38,
                indicatorColor: cs.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _PlaylistsTab(),
              _EmptyTab(
                icon: Icons.album_outlined,
                label: 'No albums yet',
                sublabel: 'Albums from YouTube Music and your library will appear here',
              ),
              _EmptyTab(
                icon: Icons.person_outline_rounded,
                label: 'No artists yet',
                sublabel: 'Follow artists on YouTube Music to see them here',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: [
        // Liked songs
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.favorite_rounded, color: cs.primary, size: 22),
          ),
          title: Text('Liked songs', style: tt.titleSmall),
          subtitle: Text('0 songs', style: tt.bodySmall),
          onTap: () {},
        ),
        // Downloads
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.download_done_rounded,
                color: Colors.white60, size: 22),
          ),
          title: Text('Downloads', style: tt.titleSmall),
          subtitle: Text('0 songs', style: tt.bodySmall),
          onTap: () {},
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: _SectionDivider(label: 'Playlists'),
        ),
        _EmptyTab(
          icon: Icons.queue_music_rounded,
          label: 'No playlists yet',
          sublabel: 'Tap + to create a playlist',
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: Colors.white38, letterSpacing: 0.8),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text(label, style: tt.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            sublabel,
            style: tt.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
