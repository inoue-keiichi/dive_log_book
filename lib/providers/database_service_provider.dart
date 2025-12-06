import 'package:dive_log_book/repositories/divelog.dart';
import 'package:dive_log_book/services/database_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_service_provider.g.dart';

@riverpod
DataAccessProvider dataAccess(Ref ref) {
  return DataAccessProvider();
}

class DataAccessProvider {
  final dbService = DatabaseService(false).open();

  Future<DiveLogRepository> createDiveLogRepository() async {
    return DiveLogRepository(await dbService);
  }
}
