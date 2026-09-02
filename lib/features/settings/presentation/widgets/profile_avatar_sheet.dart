import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';

class PresetAvatar {
  const PresetAvatar({
    required this.id,
    required this.icon,
    required this.color,
    required this.label,
  });

  final String id;
  final IconData icon;
  final Color color;
  final String label;
}

const presetAvatars = [
  PresetAvatar(id: 'sunrise', icon: Icons.wb_sunny_rounded, color: Color(0xFFF59E0B), label: 'Mentari'),
  PresetAvatar(id: 'leaf', icon: Icons.eco_rounded, color: Color(0xFF10B981), label: 'Hijau'),
  PresetAvatar(id: 'rocket', icon: Icons.rocket_launch_rounded, color: Color(0xFF6366F1), label: 'Pionir'),
  PresetAvatar(id: 'star', icon: Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), label: 'Bintang'),
  PresetAvatar(id: 'coffee', icon: Icons.coffee_rounded, color: Color(0xFF92400E), label: 'Kopi'),
  PresetAvatar(id: 'bolt', icon: Icons.bolt_rounded, color: Color(0xFFEAB308), label: 'Energi'),
  PresetAvatar(id: 'favorite', icon: Icons.favorite_rounded, color: Color(0xFFEF4444), label: 'Peduli'),
  PresetAvatar(id: 'music', icon: Icons.music_note_rounded, color: Color(0xFFEC4899), label: 'Ritme'),
  PresetAvatar(id: 'palette', icon: Icons.palette_rounded, color: Color(0xFF14B8A6), label: 'Kreatif'),
  PresetAvatar(id: 'sports', icon: Icons.sports_esports_rounded, color: Color(0xFF0EA5E9), label: 'Santai'),
  PresetAvatar(id: 'travel', icon: Icons.explore_rounded, color: Color(0xFF0891B2), label: 'Jelajah'),
  PresetAvatar(id: 'diamond', icon: Icons.diamond_rounded, color: Color(0xFF7C3AED), label: 'Berlian'),
  PresetAvatar(id: 'security', icon: Icons.shield_rounded, color: Color(0xFF475569), label: 'Aman'),
  PresetAvatar(id: 'lightbulb', icon: Icons.lightbulb_rounded, color: Color(0xFFD97706), label: 'Ide'),
  PresetAvatar(id: 'pets', icon: Icons.pets_rounded, color: Color(0xFFDB2777), label: 'Ceria'),
  PresetAvatar(id: 'balance', icon: Icons.account_balance_rounded, color: Color(0xFF059669), label: 'Stabil'),
];

class ProfileAvatarSheet extends ConsumerWidget {
  const ProfileAvatarSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ProfileAvatarSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedId = ref.watch(profileAvatarProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avatar profil', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              'Pilih gaya yang paling menggambarkanmu',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              'Avatar ini hanya simbol profil dan dapat kamu ubah kapan saja.',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: presetAvatars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: .82,
              ),
              itemBuilder: (context, index) {
                final avatar = presetAvatars[index];
                final selected = avatar.id == selectedId;
                return _AvatarChoice(
                  avatar: avatar,
                  selected: selected,
                  onTap: () async {
                    final saved = await ref
                        .read(profileAvatarProvider.notifier)
                        .setAvatar(avatar.id);
                    if (!context.mounted) return;
                    if (saved) Navigator.pop(context);
                    if (!saved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Avatar gagal disimpan. Coba lagi.')),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({required this.avatar, required this.selected, required this.onTap});

  final PresetAvatar avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Avatar ${avatar.label}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? avatar.color.withValues(alpha: .13) : colors.surfaceContainerHighest.withValues(alpha: .35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? avatar.color : colors.outlineVariant.withValues(alpha: .35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: avatar.color,
                  child: Icon(avatar.icon, color: Colors.white, size: 25),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                avatar.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? avatar.color : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PresetAvatar presetAvatarFor(String id) {
  return presetAvatars.firstWhere(
    (avatar) => avatar.id == id,
    orElse: () => presetAvatars.first,
  );
}
