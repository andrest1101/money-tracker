import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/savings_goal_entity.dart';

class SavingsGoalModel extends SavingsGoalEntity {
  const SavingsGoalModel({
    required super.id,
    required super.title,
    required super.targetAmount,
    required super.currentAmount,
    required super.deadline,
    required super.createdAt,
  });

  factory SavingsGoalModel.fromEntity(SavingsGoalEntity entity) {
    return SavingsGoalModel(
      id: entity.id,
      title: entity.title,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadline: entity.deadline,
      createdAt: entity.createdAt,
    );
  }

  factory SavingsGoalModel.fromMap(String id, Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: id,
      title: map['title'] as String? ?? '',
      targetAmount: _parseAmount(map['targetAmount']),
      currentAmount: _parseAmount(map['currentAmount']),
      deadline: _parseDate(map['deadline']),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static double _parseAmount(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  static DateTime _parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.now();
  }
}
