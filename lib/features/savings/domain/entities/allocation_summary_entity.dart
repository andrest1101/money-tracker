import '../../../transactions/domain/entities/transaction_entity.dart';

class AllocationSummaryEntity {
  const AllocationSummaryEntity({
    required this.totalAmount,
    required this.count,
    required this.latest,
  });

  final double totalAmount;
  final int count;
  final TransactionEntity? latest;
}
