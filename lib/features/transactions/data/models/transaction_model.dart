import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    required super.note,
    super.goalId,
  });

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      date: entity.date,
      note: entity.note,
      goalId: entity.goalId,
    );
  }

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      amount: _parseAmount(map['amount']),
      type: _parseType(map['type']),
      category: map['category'] as String? ?? '',
      date: _parseDate(map['date']),
      note: map['note'] as String? ?? '',
      goalId: map['goalId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      if (goalId != null) 'goalId': goalId,
    };
  }

  static double _parseAmount(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  static TransactionType _parseType(Object? raw) {
    if (raw is String) {
      return TransactionType.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => TransactionType.expense,
      );
    }
    return TransactionType.expense;
  }

  static DateTime _parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.now();
  }
}
