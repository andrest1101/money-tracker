import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';

enum PresetAvatarCategory { general, people }

class PresetAvatar {
  const PresetAvatar({
    required this.id,
    required this.icon,
    required this.color,
    required this.label,
    required this.category,
  });

  final String id;
  final IconData icon;
  final Color color;
  final String label;
  final PresetAvatarCategory category;
}

const presetAvatars = [
  // General keeps the original avatar IDs stable for existing users.
  PresetAvatar(id: 'sunrise', icon: Icons.wb_sunny_rounded, color: Color(0xFFF59E0B), label: 'Mentari', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'leaf', icon: Icons.eco_rounded, color: Color(0xFF10B981), label: 'Hijau', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'rocket', icon: Icons.rocket_launch_rounded, color: Color(0xFF6366F1), label: 'Pionir', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'star', icon: Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), label: 'Bintang', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'coffee', icon: Icons.coffee_rounded, color: Color(0xFF92400E), label: 'Kopi', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'bolt', icon: Icons.bolt_rounded, color: Color(0xFFEAB308), label: 'Energi', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'favorite', icon: Icons.favorite_rounded, color: Color(0xFFEF4444), label: 'Peduli', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'music', icon: Icons.music_note_rounded, color: Color(0xFFEC4899), label: 'Ritme', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'palette', icon: Icons.palette_rounded, color: Color(0xFF14B8A6), label: 'Kreatif', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'sports', icon: Icons.sports_esports_rounded, color: Color(0xFF0EA5E9), label: 'Santai', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'travel', icon: Icons.explore_rounded, color: Color(0xFF0891B2), label: 'Jelajah', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'diamond', icon: Icons.diamond_rounded, color: Color(0xFF7C3AED), label: 'Berlian', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'security', icon: Icons.shield_rounded, color: Color(0xFF475569), label: 'Aman', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'lightbulb', icon: Icons.lightbulb_rounded, color: Color(0xFFD97706), label: 'Ide', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'pets', icon: Icons.pets_rounded, color: Color(0xFFDB2777), label: 'Ceria', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'balance', icon: Icons.account_balance_rounded, color: Color(0xFF059669), label: 'Stabil', category: PresetAvatarCategory.general),
  PresetAvatar(id: 'person_blue', icon: Icons.face_2_rounded, color: Color(0xFF2563EB), label: 'Arga', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_pink', icon: Icons.face_3_rounded, color: Color(0xFFDB2777), label: 'Naya', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_green', icon: Icons.face_4_rounded, color: Color(0xFF059669), label: 'Raka', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_orange', icon: Icons.face_5_rounded, color: Color(0xFFEA580C), label: 'Mira', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_purple', icon: Icons.face_6_rounded, color: Color(0xFF7C3AED), label: 'Dio', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_teal', icon: Icons.person_rounded, color: Color(0xFF0F766E), label: 'Sena', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_red', icon: Icons.face_rounded, color: Color(0xFFDC2626), label: 'Luna', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_cyan', icon: Icons.face_2_rounded, color: Color(0xFF0891B2), label: 'Bima', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_indigo', icon: Icons.face_3_rounded, color: Color(0xFF4F46E5), label: 'Tara', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_lime', icon: Icons.face_4_rounded, color: Color(0xFF65A30D), label: 'Jati', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_amber', icon: Icons.face_5_rounded, color: Color(0xFFD97706), label: 'Alya', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_violet', icon: Icons.face_6_rounded, color: Color(0xFF9333EA), label: 'Fajar', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_slate', icon: Icons.person_rounded, color: Color(0xFF475569), label: 'Kirana', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_rose', icon: Icons.face_rounded, color: Color(0xFFE11D48), label: 'Reno', category: PresetAvatarCategory.people),
  PresetAvatar(id: 'person_mint', icon: Icons.face_2_rounded, color: Color(0xFF0D9488), label: 'Caca', category: PresetAvatarCategory.people),
];

class ProfileAvatarSheet extends ConsumerStatefulWidget {
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
  ConsumerState<ProfileAvatarSheet> createState() => _ProfileAvatarSheetState();
}

class _ProfileAvatarSheetState extends ConsumerState<ProfileAvatarSheet> {
  var _category = PresetAvatarCategory.people;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedId = ref.watch(profileAvatarProvider);
    final avatars = presetAvatars.where((avatar) => avatar.category == _category).toList();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.sizeOf(context).height * .78;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
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
                    'Pilih avatar manusia atau gaya umum. Kamu dapat menggantinya kapan saja.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  _CategorySelector(
                    category: _category,
                    onChanged: (category) => setState(() => _category = category),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, gridConstraints) {
                      final columns = gridConstraints.maxWidth < 360 ? 3 : 4;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: avatars.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 100,
                        ),
                        itemBuilder: (context, index) {
                          final avatar = avatars[index];
                          return _AvatarChoice(
                            avatar: avatar,
                            selected: avatar.id == selectedId,
                            onTap: () => _selectAvatar(avatar.id),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectAvatar(String id) async {
    final saved = await ref.read(profileAvatarProvider.notifier).setAvatar(id);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar gagal disimpan. Coba lagi.')),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.category, required this.onChanged});

  final PresetAvatarCategory category;
  final ValueChanged<PresetAvatarCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SegmentedButton<PresetAvatarCategory>(
      segments: const [
        ButtonSegment(value: PresetAvatarCategory.people, label: Text('Manusia'), icon: Icon(Icons.face_rounded)),
        ButtonSegment(value: PresetAvatarCategory.general, label: Text('Gaya umum'), icon: Icon(Icons.auto_awesome_rounded)),
      ],
      selected: {category},
      onSelectionChanged: (value) => onChanged(value.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        foregroundColor: WidgetStatePropertyAll(colors.onSurface),
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
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? avatar.color.withValues(alpha: .13) : colors.surfaceContainerHighest.withValues(alpha: .35),
            borderRadius: BorderRadius.circular(15),
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
                  radius: 23,
                  backgroundColor: avatar.color,
                  child: Icon(avatar.icon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                avatar.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
