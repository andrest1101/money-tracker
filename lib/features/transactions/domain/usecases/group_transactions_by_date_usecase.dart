import '../entities/transaction_entity.dart';

class GroupTransactionsByDateUseCase {
  const GroupTransactionsByDateUseCase();

  Map<String, List<TransactionEntity>> execute({
    required List<TransactionEntity> transactions,
  }) {
    final grouped = <String, List<TransactionEntity>>{};

    for (final transaction in transactions) {
      final key = _dateKey(transaction.date);
      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    return grouped;
  }

  String _dateKey(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
