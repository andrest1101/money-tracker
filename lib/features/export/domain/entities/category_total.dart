/// Total pengeluaran atau pemasukan per kategori.
class CategoryTotal {
  const CategoryTotal({
    required this.category,
    required this.transactionCount,
    required this.total,
    required this.share,
    required this.averagePerTransaction,
  });

  final String category;
  final int transactionCount;
  final int total;

  /// Porsi terhadap total pengeluaran atau total pemasukan, bernilai 0..1.
  final double share;

  final double averagePerTransaction;
}
