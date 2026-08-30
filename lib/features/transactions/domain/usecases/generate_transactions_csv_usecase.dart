import '../entities/transaction_entity.dart';

class GenerateTransactionsCsvUseCase {
  const GenerateTransactionsCsvUseCase();

  String execute(List<TransactionEntity> transactions) {
    final rows = <List<String>>[
      ['ID', 'Tanggal', 'Tipe', 'Kategori', 'Nominal', 'Catatan'],
      for (final transaction in transactions)
        [
          transaction.id,
          transaction.date.toIso8601String(),
          transaction.type.name,
          transaction.category,
          transaction.amount.toStringAsFixed(2),
          transaction.note,
        ],
    ];

    // BOM membantu spreadsheet mengenali teks Indonesia sebagai UTF-8.
    return '\uFEFF${rows.map((row) => row.map(_escape).join(',')).join('\r\n')}\r\n';
  }

  String _escape(String value) {
    final escaped = value.replaceAll('"', '""');
    if (escaped.contains(',') ||
        escaped.contains('"') ||
        escaped.contains('\n')) {
      return '"$escaped"';
    }
    return escaped;
  }
}
