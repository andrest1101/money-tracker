import 'package:flutter/material.dart';

class HelpCenterSheet extends StatelessWidget {
  const HelpCenterSheet({super.key});

  static const _faqs = [
    (
      'Bagaimana cara mencatat transaksi?',
      'Tekan tombol Catat di Beranda, pilih pemasukan atau pengeluaran, lalu isi nominal dan kategorinya. Setelah disimpan, saldo dan riwayat akan diperbarui otomatis.',
      Icons.add_circle_outline_rounded,
    ),
    (
      'Apa itu siklus anggaran?',
      'Siklus anggaran menentukan kapan periode anggaran dimulai. Contohnya, siklus tanggal 25 berarti periode berjalan dari tanggal 25 sampai tanggal 24 bulan berikutnya.',
      Icons.calendar_month_outlined,
    ),
    (
      'Bagaimana cara memakai target tabungan?',
      'Buat target di menu Target, lalu pilih Alokasikan Dana. Alokasi dicatat sebagai transaksi khusus dan saldo target akan bertambah secara atomik.',
      Icons.savings_outlined,
    ),
    (
      'Mengapa saldo bisa berwarna merah?',
      'Saldo berwarna merah berarti total pengeluaran pada periode berjalan lebih besar daripada pemasukan. Ini membantu kamu mengenali kebocoran dana lebih cepat.',
      Icons.account_balance_wallet_outlined,
    ),
    (
      'Apa fungsi Mode Privasi?',
      'Mode Privasi menyamarkan nominal pada kartu saldo di Beranda. Data transaksi tetap aman dan tidak dihapus, sehingga kamu bisa membuka nominal kembali kapan saja.',
      Icons.visibility_off_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primaryContainer, colors.secondaryContainer],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: colors.primary,
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pusat Bantuan',
                          style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jawaban singkat untuk membantu mengatur keuanganmu.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Pertanyaan umum',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              child: Column(
                children: [
                  for (var i = 0; i < _faqs.length; i++) ...[
                    ExpansionTile(
                      leading: Icon(_faqs[i].$3, color: colors.primary),
                      title: Text(
                        _faqs[i].$1,
                        style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _faqs[i].$2,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    if (i < _faqs.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Masih membutuhkan bantuan? Hubungi Andre.',
                style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
