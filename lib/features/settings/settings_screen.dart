import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Settings', style: tt.headlineMedium),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SettingsGroup(
                  title: 'Appearance',
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Pure black mode',
                      subtitle: 'Use true black backgrounds (AMOLED)',
                      trailing: Switch(value: false, onChanged: (_) {}),
                    ),
                    _SettingsTile(
                      icon: Icons.color_lens_outlined,
                      title: 'Dynamic color',
                      subtitle: 'Shift theme color to match album art',
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                  ],
                ),
                _SettingsGroup(
                  title: 'Playback',
                  children: [
                    _SettingsTile(
                      icon: Icons.high_quality_outlined,
                      title: 'Stream quality',
                      subtitle: 'High (256kbps)',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.equalizer_rounded,
                      title: 'Equalizer',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.queue_music_outlined,
                      title: 'Crossfade',
                      subtitle: 'Off',
                      onTap: () {},
                    ),
                  ],
                ),
                _SettingsGroup(
                  title: 'Local library',
                  children: [
                    _SettingsTile(
                      icon: Icons.folder_outlined,
                      title: 'Enable local library',
                      subtitle: 'Scan a folder for local audio files',
                      trailing: Switch(value: false, onChanged: (_) {}),
                    ),
                    _SettingsTile(
                      icon: Icons.folder_open_outlined,
                      title: 'Music folder',
                      subtitle: '~/Music',
                      onTap: () {},
                    ),
                  ],
                ),
                _SettingsGroup(
                  title: 'Downloads',
                  children: [
                    _SettingsTile(
                      icon: Icons.download_outlined,
                      title: 'Download format',
                      subtitle: 'Original (opus/AAC)',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.storage_outlined,
                      title: 'Storage location',
                      subtitle: '~/Music/Suiwave',
                      onTap: () {},
                    ),
                  ],
                ),
                _SettingsGroup(
                  title: 'Sync',
                  children: [
                    _SettingsTile(
                      icon: Icons.upload_outlined,
                      title: 'Export sync bundle',
                      subtitle: 'Save playlists and settings to a .suiwave file',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.download_outlined,
                      title: 'Import sync bundle',
                      subtitle: 'Restore from a .suiwave file',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.wifi_rounded,
                      title: 'LAN sync',
                      subtitle: 'Find other Suiwave devices on this network',
                      onTap: () {},
                    ),
                  ],
                ),
                _SettingsGroup(
                  title: 'About',
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Suiwave',
                      subtitle: 'Version 0.1.0',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.code_rounded,
                      title: 'Source code',
                      onTap: () {},
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: tt.labelMedium?.copyWith(
              color: cs.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Material(
          color: cs.surfaceContainer,
          borderRadius: AppTheme.cardRadius,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 0.5,
                      indent: 56,
                      endIndent: 0,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, size: 20, color: Colors.white60),
      title: Text(title, style: tt.titleSmall),
      subtitle: subtitle != null
          ? Text(subtitle!, style: tt.bodySmall)
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.white30)
              : null),
      onTap: onTap,
    );
  }
}
