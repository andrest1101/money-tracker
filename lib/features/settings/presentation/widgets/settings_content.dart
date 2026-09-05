import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'developer_card.dart';
import 'help_center_entry.dart';
import 'help_center_sheet.dart';
import 'settings_section_title.dart';
import 'settings_profile_section.dart';
import 'settings_display_section.dart';
import 'settings_financial_section.dart';
import 'settings_data_section.dart';
import 'contact_us_entry.dart';

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
      // Beri ruang ekstra agar footer tidak tertutup floating navigation bar.
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        ProfileHeader(syncState: syncState),
        const AccountSessionCard(),
        const SizedBox(height: 16),
        const SettingsSectionTitle(title: 'PREFERENSI TAMPILAN & PRIVASI'),
        const ThemeSelectionCard(),
        const PrivacyCard(),
        const SizedBox(height: 24),
        const SettingsSectionTitle(title: 'PENGELOLAAN KEUANGAN'),
        const FinancialSettingsCard(),
        const SizedBox(height: 24),
        const SettingsSectionTitle(title: 'MANAJEMEN DATA & APLIKASI'),
        const DataManagementCard(),
        const SizedBox(height: 24),
        const SettingsSectionTitle(title: 'BANTUAN'),
        HelpCenterEntry(onTap: () => _showHelpCenter(context)),
        const SizedBox(height: 10),
        const ContactUsEntry(),
        const SizedBox(height: 32),
        const DeveloperCard(),
      ],
    );
  }
}
