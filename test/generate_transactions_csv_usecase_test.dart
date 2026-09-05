import 'package:flutter_test/flutter_test.dart';

import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';
import 'package:savu/features/transactions/domain/usecases/generate_transactions_csv_usecase.dart';

void main() {
  test('generates CSV with header and escaped values', () {
    final csv = const GenerateTransactionsCsvUseCase().execute([
      TransactionEntity(
        id: '1',
        amount: 12500,
        type: TransactionType.expense,
        category: 'Makanan, siang',
        date: DateTime(2026, 8, 28, 12, 30),
        note: 'Nasi "spesial"',
      ),
    ]);

    expect(csv, contains('ID,Tanggal,Tipe,Kategori,Nominal,Catatan'));
    expect(
      csv,
      contains(
        '1,2026-08-28T12:30:00.000,expense,"Makanan, siang",12500.00,"Nasi ""spesial"""',
      ),
    );
  });

  test('generates header for an empty transaction list', () {
    final csv = const GenerateTransactionsCsvUseCase().execute(const []);

    expect(csv, contains('ID,Tanggal,Tipe,Kategori,Nominal,Catatan'));
  });
}
