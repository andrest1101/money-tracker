import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/export_repository.dart';
import '../repositories/export_repository_impl.dart';

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepositoryImpl();
});
