import 'package:flutter_test/flutter_test.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';
import 'package:savu/features/transactions/domain/usecases/group_transactions_by_date_usecase.dart';

void main() {
  const useCase = GroupTransactionsByDateUseCase();

  TransactionEntity makeTransaction({
    required DateTime date,
    String category = 'Makanan',
    double amount = 10000,
    TransactionType type = TransactionType.expense,
  }) {
    return TransactionEntity(
      id: 'tx-${date.millisecondsSinceEpoch}',
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: '',
    );
  }

  group('GroupTransactionsByDateUseCase', () {
    test('data kosong menghasilkan map kosong', () {
      final result = useCase.execute(transactions: []);
      expect(result, isEmpty);
    });

    test('transaksi satu tanggal terkelompok bersama', () {
      final tx1 = makeTransaction(date: DateTime(2026, 8, 26, 10));
      final tx2 = makeTransaction(
        date: DateTime(2026, 8, 26, 14),
        category: 'Transportasi',
      );

      final result = useCase.execute(transactions: [tx1, tx2]);

      expect(result.length, 1);
      expect(result.containsKey('26 Agustus 2026'), isTrue);
      expect(result['26 Agustus 2026']!.length, 2);
    });

    test('transaksi tanggal berbeda terkelompok terpisah', () {
      final tx1 = makeTransaction(date: DateTime(2026, 8, 26));
      final tx2 = makeTransaction(date: DateTime(2026, 8, 25));
      final tx3 = makeTransaction(
        date: DateTime(2026, 7, 15),
        category: 'Gaji Part-time',
        type: TransactionType.income,
      );

      final result = useCase.execute(transactions: [tx1, tx2, tx3]);

      expect(result.length, 3);
      expect(result.containsKey('26 Agustus 2026'), isTrue);
      expect(result.containsKey('25 Agustus 2026'), isTrue);
      expect(result.containsKey('15 Juli 2026'), isTrue);
    });

    test('format bulan benar dalam bahasa Indonesia', () {
      final tx = makeTransaction(date: DateTime(2026, 1, 1));

      final result = useCase.execute(transactions: [tx]);

      expect(result.containsKey('1 Januari 2026'), isTrue);
    });

    test('menjaga urutan transaksi asli dalam satu grup', () {
      final tx1 = makeTransaction(date: DateTime(2026, 8, 26, 8));
      final tx2 = makeTransaction(date: DateTime(2026, 8, 26, 12));
      final tx3 = makeTransaction(date: DateTime(2026, 8, 26, 16));

      final result = useCase.execute(transactions: [tx1, tx2, tx3]);

      expect(result['26 Agustus 2026']![0].id, tx1.id);
      expect(result['26 Agustus 2026']![1].id, tx2.id);
      expect(result['26 Agustus 2026']![2].id, tx3.id);
    });
  });
}
