/// Status target tabungan pada saat laporan dibuat.
enum GoalStatus { active, completed, archived }

/// Progress satu target tabungan untuk sheet Target Tabungan.
class GoalProgress {
  const GoalProgress({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.deadline,
    required this.daysRemaining,
    required this.status,
    required this.allocatedInPeriod,
    required this.allocationCountInPeriod,
  });

  final String id;
  final String title;
  final int currentAmount;
  final int targetAmount;
  final DateTime deadline;
  final int daysRemaining;
  final GoalStatus status;

  /// Total alokasi yang masuk ke target ini di dalam periode ekspor.
  final int allocatedInPeriod;
  final int allocationCountInPeriod;

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0).toDouble();
  }

  int get remainingAmount {
    if (currentAmount >= targetAmount) return 0;
    return targetAmount - currentAmount;
  }
}
