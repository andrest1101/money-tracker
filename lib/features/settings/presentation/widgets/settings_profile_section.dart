import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'account_security_sheet.dart';
import 'profile_avatar_sheet.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.syncState});

  final AsyncValue<List<TransactionEntity>> syncState;

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
                'Informasi ini tersimpan di perangkatmu dan membantu menyesuaikan pengalaman Savu.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ProfileDetailTile(
                icon: Icons.badge_outlined,
                label: 'Profil pengguna',
                value: profileType,
              ),
              ProfileDetailTile(
                icon: Icons.calendar_month_outlined,
                label: 'Siklus anggaran',
                value: 'Dimulai tanggal $budgetCycle setiap bulan',
              ),
              ProfileDetailTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Batas anggaran',
                value: budgetLimit == null
                    ? 'Belum diatur'
                    : formatRupiah(budgetLimit),
              ),
              ProfileDetailTile(
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
    showDialog<void>(
      context: context,
      builder: (_) =>
          EditProfileDialog(initialName: userName, initialType: profileType),
    );
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
    final isDark = theme.brightness == Brightness.dark;
    final authUser = ref.watch(currentUserProvider);
    final isGuest = authUser?.isAnonymous ?? true;
    final avatarId = ref.watch(profileAvatarProvider);
    final avatar = presetAvatarFor(avatarId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: isDark ? cs.surfaceContainerHigh : cs.primaryContainer,
        surfaceTintColor: Colors.transparent,
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
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => ProfileAvatarSheet.show(context),
                    customBorder: const CircleBorder(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              ),
                          child: CircleAvatar(
                            key: ValueKey(avatar.id),
                            radius: 32,
                            backgroundColor: avatar.color,
                            child: Icon(
                              avatar.icon,
                              color: Colors.white,
                              size: 31,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                      ],
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
                        '$profileType  •  Ketuk avatar untuk mengganti',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      SyncStatusBadge(syncState: syncState),
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

class AccountSessionCard extends ConsumerWidget {
  const AccountSessionCard({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    final isGuest = user?.isAnonymous ?? true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          isGuest ? Icons.warning_amber_rounded : Icons.logout_rounded,
          color: isGuest ? Colors.orange.shade700 : null,
        ),
        title: Text(isGuest ? 'Keluar dari akun guest?' : 'Keluar dari akun?'),
        content: Text(
          isGuest
              ? 'Akun guest belum memiliki akses pemulihan. Jika keluar, data guest ini bisa tidak dapat dibuka kembali.'
              : 'Kamu bisa masuk kembali menggunakan metode login yang sama atau akun lain.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Keluar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = user?.isAnonymous ?? true;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        elevation: 0,
        color: colors.surfaceContainerHigh,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isGuest
                ? colors.tertiaryContainer
                : colors.primaryContainer,
            child: Icon(
              isGuest
                  ? Icons.person_outline_rounded
                  : Icons.verified_user_rounded,
              color: isGuest
                  ? colors.onTertiaryContainer
                  : colors.onPrimaryContainer,
            ),
          ),
          title: Text(
            isGuest ? 'Akun guest' : 'Akun terhubung',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            isGuest
                ? 'Data hanya terikat pada device ini'
                : user?.email ?? 'Akun Firebase',
            overflow: TextOverflow.ellipsis,
          ),
          trailing: TextButton(
            onPressed: () => _signOut(context, ref),
            child: Text(isGuest ? 'Ganti' : 'Keluar'),
          ),
        ),
      ),
    );
  }
}

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({
    super.key,
    required this.initialName,
    required this.initialType,
  });

  final String initialName;
  final String initialType;

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  static const _profileTypes = [
    'Mahasiswa',
    'Karyawan',
    'Freelancer',
    'Wirausaha',
    'Lainnya',
  ];

  late final TextEditingController _nameController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final nameSaved = await ref
        .read(userNameProvider.notifier)
        .setUserName(name);
    final typeSaved = await ref
        .read(userProfileTypeProvider.notifier)
        .setProfileType(_selectedType);
    if (!mounted) return;
    if (!nameSaved || !typeSaved) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.onError,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Profil gagal disimpan.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Profil diperbarui.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
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
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Kamu seorang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              isExpanded: true,
              items: _profileTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ],
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    );
  }
}

class ProfileDetailTile extends StatelessWidget {
  const ProfileDetailTile({
    super.key,
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

class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key, required this.syncState});

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
