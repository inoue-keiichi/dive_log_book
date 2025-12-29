import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../providers/database_service_provider.dart';

class StatisticsResult {
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<DiveDuration> diveDuration;
  final ValueNotifier<int> diveCount;
  final ValueNotifier<String?> error;

  StatisticsResult({
    required this.isLoading,
    required this.diveDuration,
    required this.diveCount,
    required this.error,
  });
}

class DiveDuration {
  final int hour;
  final int minute;

  DiveDuration({required this.hour, required this.minute});
}

StatisticsResult useStatistics(DataAccessProvider da) {
  final isLoading = useState(true);
  final diveDuration = useState<DiveDuration>(DiveDuration(hour: 0, minute: 0));
  final diveCount = useState(0);
  final error = useState<String?>(null);
  // final isScreenVisible = useState(true);

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      error.value = null;

      final repository = await da.createDiveLogRepository();
      final results = await Future.wait([
        repository.getTotalDivingTimeMinutes(),
        repository.getTotalDiveCount(),
      ]);

      diveDuration.value = _getDiveDuration(results[0]);
      diveCount.value = results[1];
    } catch (e) {
      error.value = '統計データの読み込みに失敗しました: ${e.toString()}';
      if (kDebugMode) {
        print('Statistics loading error: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 画面の可視性を監視してデータを再読み込み
  useEffect(() {
    // 初回読み込み
    loadStatistics();
    return null;
  }, []);

  return StatisticsResult(
    isLoading: isLoading,
    diveDuration: diveDuration,
    diveCount: diveCount,
    error: error,
  );
}

DiveDuration _getDiveDuration(int minutes) {
  if (minutes <= 0) return DiveDuration(hour: 0, minute: 0);

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  return DiveDuration(hour: hours, minute: remainingMinutes);
}
