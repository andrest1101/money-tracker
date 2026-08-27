import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeModeProvider);
    final budgetLimit = ref.watch(budgetLimitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: 'PREFERENSI TAMPILAN'),
          _ThemeSelectionCard(currentTheme: currentTheme),
          
          const SizedBox(height: 16),
          _SectionHeader(title: 'PENGELOLAAN KEUANGAN'),
          _BudgetLimitTile(currentLimit: budgetLimit),
          
          const SizedBox(height: 16),
          _SectionHeader(title: 'TENTANG APLIKASI'),
          _AboutAppSection(),
        ],
      ),
    );
  }
}

// ── Komponen Pembantu ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ThemeSelectionCard extends ConsumerWidget {
  const _ThemeSelectionCard({required this.currentTheme});

  final ThemeMode currentTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_outlined, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Tema Aplikasi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ThemeChip(
                    icon: Icons.brightness_auto_rounded,
                    label: 'Sistem',
                    selected: currentTheme == ThemeMode.system,
                    onTap: () => ref
                        .read(appThemeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                  const SizedBox(width: 8),
                  _ThemeChip(
                    icon: Icons.light_mode_rounded,
                    label: 'Terang',
                    selected: currentTheme == ThemeMode.light,
                    onTap: () => ref
                        .read(appThemeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 8),
                  _ThemeChip(
                    icon: Icons.dark_mode_rounded,
                    label: 'Gelap',
                    selected: currentTheme == ThemeMode.dark,
                    onTap: () => ref
                        .read(appThemeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.15)
                : cs.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.6)
                  : cs.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetLimitTile extends ConsumerWidget {
  const _BudgetLimitTile({required this.currentLimit});

  final double? currentLimit;

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _SetBudgetDialog(currentLimit: currentLimit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final isSet = currentLimit != null && currentLimit! > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias, // for InkWell ripple
        child: InkWell(
          onTap: () => _showSetBudgetDialog(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined, color: cs.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batas Anggaran Bulanan',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isSet)
                        Text(
                          formatRupiah(currentLimit!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        Text(
                          'Belum diatur. Tap untuk mengatur.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetBudgetDialog extends ConsumerStatefulWidget {
  const _SetBudgetDialog({required this.currentLimit});

  final double? currentLimit;

  @override
  ConsumerState<_SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends ConsumerState<_SetBudgetDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.currentLimit != null && widget.currentLimit! > 0) {
      _controller.text = formatRupiah(widget.currentLimit!).replaceFirst('Rp ', '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final raw = _controller.text.trim().replaceAll('.', '');
    final limit = double.tryParse(raw);
    
    if (limit != null && limit >= 0) {
      // 0 means removing the limit.
      ref.read(budgetLimitProvider.notifier).setBudgetLimit(limit == 0 ? null : limit);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(limit == 0 ? 'Batas anggaran dimatikan' : 'Batas anggaran disimpan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Batas Anggaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Atur batas pengeluaran bulanan agar aplikasi dapat memberikan peringatan sebelum kamu boros.'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Batas Nominal',
              hintText: 'Misal: 2.500.000',
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'Isi 0 untuk mematikan peringatan',
            ),
            onSubmitted: (_) => _save(context),
          ),
        ],
      ),
      actions: [
        TextButton(
           onPressed: () => Navigator.of(context).pop(),
           child: const Text('Batal'),
        ),
        FilledButton(
           onPressed: () => _save(context),
           child: const Text('Simpan'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _AboutAppSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
             ListTile(
              leading: Icon(Icons.info_outline_rounded, color: cs.primary),
              title: const Text('Versi Aplikasi'),
              trailing: const Text('v1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
             const Divider(height: 1, indent: 16, endIndent: 16),
             ListTile(
              leading: Icon(Icons.help_outline_rounded, color: cs.primary),
              title: const Text('Bantuan & FAQ'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                // Future Placeholder for Help Screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Halaman bantuan segera hadir!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
