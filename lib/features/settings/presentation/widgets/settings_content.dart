import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
import '../../../transactions/presentation/providers/transaction_export_controller.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import 'developer_card.dart';
import 'help_center_entry.dart';
import 'help_center_sheet.dart';
import 'settings_section_title.dart';
import 'account_security_sheet.dart';

void _showSettingsSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.inverseSurface,
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline,
              color: isError
                  ? Theme.of(context).colorScheme.onError
                  : Theme.of(context).colorScheme.onInverseSurface,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

void _showHelpCenter(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const HelpCenterSheet(),
  );
}

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(transactionsStreamProvider, (_, next) {
      if (next.hasValue) {
        ref.read(lastSuccessfulSyncProvider.notifier).markNow();
      }
    });
    final syncState = ref.watch(transactionsStreamProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _ProfileHeader(syncState: syncState),
        const SizedBox(height: 16),
        const SettingsSectionTitle(title: 'PREFERENSI TAMPILAN & PRIVASI'),
        const _ThemeSelectionCard(),
        const _PrivacyCard(),
        const SizedBox(height: 24),
        const SettingsSectionTitle(title: 'PENGELOLAAN KEUANGAN'),
        const _FinancialSettingsCard(),
        const SizedBox(height: 24),
        const SettingsSectionTitle(title: 'MANAJEMEN DATA & APLIKASI'),
        const _DataManagementCard(),
        const SizedBox(height: 24),
        const SettingsSectionTitle(title: 'BANTUAN'),
        HelpCenterEntry(onTap: () => _showHelpCenter(context)),
        const SizedBox(height: 32),
        const DeveloperCard(),
      ],
    );
  }
}

// ── Komponen Pembantu ────────────────────────────────────────────────────────

// ── 1. Profile Header ────────────────────────────────────────────────────────

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.syncState});

  final AsyncValue<List<TransactionEntity>> syncState;

  static const _profileTypes = [
    'Mahasiswa',
    'Karyawan',
    'Freelancer',
    'Wirausaha',
    'Lainnya',
  ];

  void _showProfileDetails(
    BuildContext context,
    WidgetRef ref, {
    required String userName,
    required String profileType,
    required double? budgetLimit,
    required int budgetCycle,
    required bool privacyMode,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil keuangan',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Informasi ini tersimpan di perangkatmu dan membantu menyesuaikan pengalaman MoneyTracker.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _ProfileDetailTile(
                icon: Icons.badge_outlined,
                label: 'Profil pengguna',
                value: profileType,
              ),
              _ProfileDetailTile(
                icon: Icons.calendar_month_outlined,
                label: 'Siklus anggaran',
                value: 'Dimulai tanggal $budgetCycle setiap bulan',
              ),
              _ProfileDetailTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Batas anggaran',
                value: budgetLimit == null
                    ? 'Belum diatur'
                    : formatRupiah(budgetLimit),
              ),
              _ProfileDetailTile(
                icon: privacyMode
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                label: 'Mode privasi',
                value: privacyMode ? 'Aktif di Beranda' : 'Tidak aktif',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditProfileDialog(
                    context,
                    ref,
                    userName: userName,
                    profileType: profileType,
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profil'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref, {
    required String userName,
    required String profileType,
  }) {
    final nameController = TextEditingController(text: userName);
    var selectedType = profileType;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama lengkap atau panggilan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Kamu seorang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _profileTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedType = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final nameSaved = await ref
                    .read(userNameProvider.notifier)
                    .setUserName(name);
                final typeSaved = await ref
                    .read(userProfileTypeProvider.notifier)
                    .setProfileType(selectedType);
                if (!context.mounted) return;
                if (!nameSaved || !typeSaved) {
                  _showSettingsSnackBar(
                    context,
                    message: 'Profil gagal disimpan.',
                    isError: true,
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                _showSettingsSnackBar(context, message: 'Profil diperbarui.');
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    ).whenComplete(nameController.dispose);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final profileType = ref.watch(userProfileTypeProvider);
    final budgetLimit = ref.watch(budgetLimitProvider);
    final budgetCycle = ref.watch(budgetCycleDateProvider);
    final privacyMode = ref.watch(privacyModeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authUser = ref.watch(currentUserProvider);
    final isGuest = authUser?.isAnonymous ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: cs.primaryContainer.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () => _showProfileDetails(
            context,
            ref,
            userName: userName,
            profileType: profileType,
            budgetLimit: budgetLimit,
            budgetCycle: budgetCycle,
            privacyMode: privacyMode,
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Halo, $userName',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            onPressed: () => _showProfileDetails(
                              context,
                              ref,
                              userName: userName,
                              profileType: profileType,
                              budgetLimit: budgetLimit,
                              budgetCycle: budgetCycle,
                              privacyMode: privacyMode,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: cs.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$profileType  •  Ketuk untuk melihat detail',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _SyncStatusBadge(syncState: syncState),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isGuest
                            ? () => showAccountSecuritySheet(context)
                            : null,
                        borderRadius: BorderRadius.circular(30),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGuest
                                  ? Icons.person_outline_rounded
                                  : Icons.verified_user_rounded,
                              size: 16,
                              color: isGuest
                                  ? cs.tertiary
                                  : Colors.green.shade700,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                isGuest
                                    ? 'Akun guest • Amankan sekarang'
                                    : 'Akun terhubung',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isGuest
                                      ? cs.tertiary
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
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
      ),
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(label, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SyncStatusBadge extends ConsumerWidget {
  const _SyncStatusBadge({required this.syncState});

  final AsyncValue<List<TransactionEntity>> syncState;

  String _lastSyncLabel(DateTime? value) {
    if (value == null) return 'Belum ada sinkronisasi';
    final elapsed = DateTime.now().difference(value);
    if (elapsed.inMinutes < 1) return 'Baru saja diperbarui';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} menit lalu';
    if (elapsed.inDays < 1) return '${elapsed.inHours} jam lalu';
    return '${elapsed.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lastSync = ref.watch(lastSuccessfulSyncProvider);
    final (label, icon, color, retry) = syncState.when(
      loading: () => (
        'Menyiapkan sinkronisasi',
        Icons.sync_rounded,
        Colors.orange.shade800,
        false,
      ),
      error: (_, __) => (
        'Offline / sinkronisasi gagal',
        Icons.cloud_off_rounded,
        colors.error,
        true,
      ),
      data: (_) => (
        'Tersinkronisasi • ${_lastSyncLabel(lastSync)}',
        Icons.cloud_done_rounded,
        Colors.green.shade800,
        false,
      ),
    );

    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: retry ? () => ref.invalidate(transactionsStreamProvider) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (retry) ...[
                const SizedBox(width: 4),
                Icon(Icons.refresh_rounded, size: 13, color: color),
              ],
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
                    onTap: () => _saveTheme(context, ref, ThemeMode.system),
                  ),
                  const SizedBox(width: 8),
                  _ThemeChip(
                    icon: Icons.light_mode_rounded,
                    label: 'Terang',
                    selected: currentTheme == ThemeMode.light,
                    onTap: () => _saveTheme(context, ref, ThemeMode.light),
                  ),
                  const SizedBox(width: 8),
                  _ThemeChip(
                    icon: Icons.dark_mode_rounded,
                    label: 'Gelap',
                    selected: currentTheme == ThemeMode.dark,
                    onTap: () => _saveTheme(context, ref, ThemeMode.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    final saved = await ref
        .read(appThemeModeProvider.notifier)
        .setThemeMode(mode);
    if (!context.mounted) return;
    _showSettingsSnackBar(
      context,
      message: saved ? 'Tema aplikasi diperbarui.' : 'Tema gagal disimpan.',
      isError: !saved,
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
          onChanged: (value) async {
            final saved = await ref.read(privacyModeProvider.notifier).toggle();
            if (!context.mounted) return;
            _showSettingsSnackBar(
              context,
              message: saved
                  ? 'Mode privasi ${value ? 'diaktifkan' : 'dinonaktifkan'}. '
                        'Perubahan diterapkan di Beranda.'
                  : 'Mode privasi gagal disimpan.',
              isError: !saved,
            );
          },
          title: Text(
            'Mode Privasi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text('Sembunyikan nominal saldo di Beranda'),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPrivacyMode
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.onSurfaceVariant.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPrivacyMode
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: isPrivacyMode ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ── 3. Pengelolaan Keuangan ──────────────────────────────────────────────────

class _FinancialSettingsCard extends ConsumerWidget {
  const _FinancialSettingsCard();

  void _showSetBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    double? currentLimit,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _SetBudgetDialog(currentLimit: currentLimit),
    );
  }

  void _showSetCycleDialog(
    BuildContext context,
    WidgetRef ref,
    int currentDay,
  ) {
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
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: cs.primary,
                ),
              ),
              title: Text(
                'Batas Anggaran Bulanan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: isSet
                  ? Text(
                      formatRupiah(currentLimit),
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.orange.shade800,
                ),
              ),
              title: Text(
                'Siklus Anggaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.currentLimit != null && widget.currentLimit! > 0) {
      _controller.text = formatRupiah(
        widget.currentLimit!,
      ).replaceFirst('Rp ', '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final raw = _controller.text.trim().replaceAll('.', '');
    final limit = double.tryParse(raw);

    if (limit == null || limit < 0) {
      setState(() => _errorText = 'Masukkan nominal anggaran yang valid.');
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });
    final saved = await ref
        .read(budgetLimitProvider.notifier)
        .setBudgetLimit(limit == 0 ? null : limit);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (!saved) {
      _showSettingsSnackBar(
        context,
        message: 'Batas anggaran gagal disimpan.',
        isError: true,
      );
      return;
    }
    Navigator.of(context).pop();
    _showSettingsSnackBar(context, message: 'Batas anggaran diperbarui.');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Batas Anggaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atur batas pengeluaran bulanan agar aplikasi dapat memberikan peringatan sebelum kamu boros.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Batas Nominal',
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'Isi 0 untuk mematikan peringatan',
              errorText: _errorText,
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
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
          const Text(
            'Kapan biasanya kamu menerima uang bulanan/gajian? Anggaran akan di-reset pada tanggal ini.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedDay,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: List.generate(28, (index) => index + 1)
                .map(
                  (day) =>
                      DropdownMenuItem(value: day, child: Text('Tanggal $day')),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedDay = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            final saved = await ref
                .read(budgetCycleDateProvider.notifier)
                .setDate(_selectedDay);
            if (!mounted) return;
            if (!saved) {
              _showSettingsSnackBar(
                context,
                message: 'Siklus anggaran gagal disimpan.',
                isError: true,
              );
              return;
            }
            Navigator.of(context).pop();
            _showSettingsSnackBar(
              context,
              message: 'Siklus anggaran diperbarui.',
            );
          },
          child: const Text('Simpan'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// ── 4. Data Management & Danger Zone ─────────────────────────────────────────

class _DataManagementCard extends ConsumerWidget {
  const _DataManagementCard();

  void _showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showDeleteAllDialog(BuildContext context, WidgetRef ref) async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          size: 48,
          color: Colors.red,
        ),
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
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus Semua'),
          ),
        ],
      ),
    );
    if (firstConfirm != true || !context.mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => const _FinalDeleteConfirmationDialog(),
    );
    if (secondConfirm != true || !context.mounted) return;

    final success = await ref
        .read(savingsActionsControllerProvider.notifier)
        .deleteAllData();
    if (!context.mounted) return;
    _showSettingsSnackBar(
      context,
      message: success
          ? 'Semua transaksi dan target berhasil dihapus.'
          : 'Data gagal dihapus. Coba lagi.',
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final transactions = ref.watch(transactionsStreamProvider);
    final isExporting = ref
        .watch(transactionExportControllerProvider)
        .isLoading;

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
              enabled: !isExporting,
              onTap: () async {
                final items = transactions.value ?? const [];
                if (items.isEmpty) {
                  _showInfoMessage(
                    context,
                    'Belum ada transaksi untuk diekspor.',
                  );
                  return;
                }
                final shared = await ref
                    .read(transactionExportControllerProvider.notifier)
                    .export(items);
                if (!context.mounted) return;
                _showSettingsSnackBar(
                  context,
                  message: shared
                      ? 'CSV transaksi siap dibagikan.'
                      : 'Ekspor CSV gagal. Coba lagi.',
                  isError: !shared,
                );
              },
              leading: Icon(Icons.download_rounded, color: cs.primary),
              title: const Text('Ekspor Data ke CSV'),
              subtitle: Text(
                isExporting
                    ? 'Menyiapkan file...'
                    : 'Bagikan riwayat transaksi sebagai spreadsheet',
              ),
              trailing: isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              onTap: () => _showDeleteAllDialog(context, ref),
              leading: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'Hapus Seluruh Data',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Reset akun dan mulai dari nol'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalDeleteConfirmationDialog extends StatefulWidget {
  const _FinalDeleteConfirmationDialog();

  @override
  State<_FinalDeleteConfirmationDialog> createState() =>
      _FinalDeleteConfirmationDialogState();
}

class _FinalDeleteConfirmationDialogState
    extends State<_FinalDeleteConfirmationDialog> {
  bool _hasConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.gpp_maybe_rounded, color: Colors.red, size: 44),
      title: const Text('Konfirmasi terakhir'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data transaksi, alokasi, dan target tabungan akan dihapus permanen. Pastikan kamu benar-benar ingin melanjutkan.',
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _hasConfirmed,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Saya mengerti bahwa tindakan ini tidak dapat dibatalkan.',
            ),
            onChanged: (value) {
              setState(() => _hasConfirmed = value ?? false);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _hasConfirmed ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('HAPUS SEMUA'),
        ),
      ],
    );
  }
}
