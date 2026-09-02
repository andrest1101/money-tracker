import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ContactUsEntry extends StatelessWidget {
  const ContactUsEntry({super.key});

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ContactUsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: () => _openSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.tertiaryContainer,
                  foregroundColor: colors.onTertiaryContainer,
                  child: const Icon(Icons.forum_outlined),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hubungi Kami',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Kirim saran atau laporkan masalah aplikasi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactUsSheet extends StatelessWidget {
  const _ContactUsSheet();

  Future<void> _shareFeedback(BuildContext context) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: 'Halo tim MoneyTracker,\n\nSaya ingin memberikan masukan:\n\n',
        subject: 'Masukan untuk MoneyTracker',
      ),
    );
    if (!context.mounted || result.status == ShareResultStatus.dismissed) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mediaQuery = MediaQuery.of(context);
          final keyboardInset = mediaQuery.viewInsets.bottom;
          final maxHeight = mediaQuery.size.height * .8;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + keyboardInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text('Hubungi Kami', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              'Bantu MoneyTracker jadi lebih baik',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Punya saran, menemukan bug, atau ingin berbagi pengalaman? Gunakan aplikasi pilihanmu untuk mengirim feedback.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_outlined, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sertakan jenis perangkat dan langkah terjadinya masalah agar feedback lebih mudah ditindaklanjuti.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _shareFeedback(context),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Kirim feedback'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
