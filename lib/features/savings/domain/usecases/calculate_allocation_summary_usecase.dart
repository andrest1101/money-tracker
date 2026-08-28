import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/allocation_summary_entity.dart';

class CalculateAllocationSummaryUseCase {
  const CalculateAllocationSummaryUseCase();

  AllocationSummaryEntity execute(List<TransactionEntity> allocations) {
    final sorted = List<TransactionEntity>.from(allocations)
      ..sort((a, b) => b.date.compareTo(a.date));
    return AllocationSummaryEntity(
      totalAmount: allocations.fold(0, (sum, item) => sum + item.amount),
      count: allocations.length,
      latest: sorted.isEmpty ? null : sorted.first,
    );
  }
}
