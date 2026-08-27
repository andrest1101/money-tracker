enum TransactionType { income, expense }

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
    this.goalId,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String note;
  final String? goalId;

  bool get isExpense => type == TransactionType.expense;
  bool get isAllocation => goalId != null;

  TransactionEntity copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
    String? Function()? goalId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      goalId: goalId != null ? goalId() : this.goalId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity &&
        other.id == id &&
        other.amount == amount &&
        other.type == type &&
        other.category == category &&
        other.date == date &&
        other.note == note &&
        other.goalId == goalId;
  }

  @override
  int get hashCode => Object.hash(id, amount, type, category, date, note, goalId);
}
