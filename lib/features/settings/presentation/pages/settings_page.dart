import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
// import 'package:url_launcher/url_launcher.dart'; // Akan digunakan nanti jika perlu buka web

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              // TODO: Tampilkan FAQ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pusat Bantuan segera hadir')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 16),
          const _SectionTitle(title: 'PREFERENSI TAMPILAN & PRIVASI'),
          const _ThemeSelectionCard(),
          const _PrivacyCard(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'PENGELOLAAN KEUANGAN'),
          const _FinancialSettingsCard(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'MANAJEMEN DATA & APLIKASI'),
          const _DataManagementCard(),
          const SizedBox(height: 32),
          const _DeveloperCard(),
        ],
      ),
    );
  }
}

// ── Komponen Pembantu ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ── 1. Profile Header ────────────────────────────────────────────────────────

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Panggilan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Misal: Andre',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(userNameProvider.notifier).setUserName(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: cs.primaryContainer.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showEditNameDialog(context, ref, userName),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: cs.primary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Halo, $userName',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          onPressed: () => _showEditNameDialog(context, ref, userName),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: cs.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_done_rounded, size: 14, color: Colors.green.shade800),
                          const SizedBox(width: 6),
                          Text(
                            'Tersinkronisasi',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 2. Preferensi Tampilan & Privasi ─────────────────────────────────────────

class _ThemeSelectionCard extends ConsumerWidget {
  const _ThemeSelectionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeModeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
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
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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

class _PrivacyCard extends ConsumerWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(privacyModeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SwitchListTile(
          value: isPrivacyMode,
          onChanged: (value) => ref.read(privacyModeProvider.notifier).toggle(),
          title: Text(
            'Mode Privasi',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Sembunyikan nominal saldo di Beranda'),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPrivacyMode ? cs.primary.withValues(alpha: 0.1) : cs.onSurfaceVariant.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPrivacyMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: isPrivacyMode ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

// ── 3. Pengelolaan Keuangan ──────────────────────────────────────────────────

class _FinancialSettingsCard extends ConsumerWidget {
  const _FinancialSettingsCard();

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref, double? currentLimit) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _SetBudgetDialog(currentLimit: currentLimit),
    );
  }

  void _showSetCycleDialog(BuildContext context, WidgetRef ref, int currentDay) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _SetCycleDialog(currentDay: currentDay),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLimit = ref.watch(budgetLimitProvider);
    final currentCycle = ref.watch(budgetCycleDateProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final isSet = currentLimit != null && currentLimit > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              onTap: () => _showSetBudgetDialog(context, ref, currentLimit),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet_outlined, color: cs.primary),
              ),
              title: Text(
                'Batas Anggaran Bulanan',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: isSet
                  ? Text(
                      formatRupiah(currentLimit),
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                    )
                  : const Text('Belum diatur'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(height: 1, indent: 64),
            ListTile(
              onTap: () => _showSetCycleDialog(context, ref, currentCycle),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_month_outlined, color: Colors.orange.shade800),
              ),
              title: Text(
                'Siklus Anggaran',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Dimulai tanggal $currentCycle setiap bulan'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ],
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

  void _save() {
    final raw = _controller.text.trim().replaceAll('.', '');
    final limit = double.tryParse(raw);
    
    if (limit != null && limit >= 0) {
      ref.read(budgetLimitProvider.notifier).setBudgetLimit(limit == 0 ? null : limit);
      Navigator.of(context).pop();
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
              prefixText: 'Rp ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              helperText: 'Isi 0 untuk mematikan peringatan',
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _SetCycleDialog extends ConsumerStatefulWidget {
  const _SetCycleDialog({required this.currentDay});
  final int currentDay;

  @override
  ConsumerState<_SetCycleDialog> createState() => _SetCycleDialogState();
}

class _SetCycleDialogState extends ConsumerState<_SetCycleDialog> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tanggal Siklus'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kapan biasanya kamu menerima uang bulanan/gajian? Anggaran akan di-reset pada tanggal ini.'),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedDay,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: List.generate(28, (index) => index + 1)
                .map((day) => DropdownMenuItem(value: day, child: Text('Tanggal $day')))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedDay = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            ref.read(budgetCycleDateProvider.notifier).setDate(_selectedDay);
            Navigator.of(context).pop();
          },
          child: const Text('Simpan'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// ── 4. Data Management & Danger Zone ─────────────────────────────────────────

class _DataManagementCard extends StatelessWidget {
  const _DataManagementCard();

  void _showWipDialog(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $feature akan segera hadir!')),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Tindakan ini akan menghapus SELURUH transaksi dan target tabungan secara permanen dari server. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showWipDialog(context, 'Hapus Data Masal'); // Placeholder until implemented
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus Semua'),
          ),
        ],
      ),
    );
  }

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
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              onTap: () => _showWipDialog(context, 'Ekspor ke CSV'),
              leading: Icon(Icons.download_rounded, color: cs.primary),
              title: const Text('Ekspor Data ke CSV'),
              subtitle: const Text('Simpan riwayat transaksi sebagai spreadsheet'),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              onTap: () => _showDeleteAllDialog(context),
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: const Text('Hapus Seluruh Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              subtitle: const Text('Reset akun dan mulai dari nol'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 5. Developer Card ────────────────────────────────────────────────────────

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.code_rounded, color: cs.primary.withValues(alpha: 0.5), size: 32),
          const SizedBox(height: 12),
          Text(
            'MoneyTracker v1.0.0',
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dibuat dengan ❤️ oleh Andre',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
