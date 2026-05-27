import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/audio/audio_provider.dart';
import 'mini_player.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _NavDestination(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, path: '/home'),
    _NavDestination(label: 'Search', icon: Icons.search_rounded, activeIcon: Icons.search_rounded, path: '/search'),
    _NavDestination(label: 'Library', icon: Icons.library_music_outlined, activeIcon: Icons.library_music_rounded, path: '/library'),
    _NavDestination(label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, path: '/settings'),
  ];

  int _locationToIndex(String location) {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerState.hasTrack) const MiniPlayer(),
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              context.go(_destinations[index].path);
            },
            destinations: _destinations.map((d) {
              return NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.activeIcon),
                label: d.label,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
