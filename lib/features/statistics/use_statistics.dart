import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../providers/database_service_provider.dart';

class StatisticsResult {
  final bool isLoading;
  final int totalMinutes;
  final int diveCount;
  final String? error;
  final DiveDuration diveDuration;

  StatisticsResult({
    required this.isLoading,
    required this.totalMinutes,
    required this.diveCount,
    this.error,
    required this.diveDuration,
  });
}

class DiveDuration {
  final int hour;
  final int minute;

  DiveDuration({required this.hour, required this.minute});
}

StatisticsResult useStatistics(DataAccessProvider da) {
  final isLoading = useState(true);
  final totalMinutes = useState(0);
  final diveCount = useState(0);
  final error = useState<String?>(null);
  final isScreenVisible = useState(true);

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      error.value = null;

      final repository = await da.createDiveLogRepository();
      final results = await Future.wait([
        repository.getTotalDivingTimeMinutes(),
        repository.getDiveCountWithTime(),
      ]);

      totalMinutes.value = results[0];
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
    void onAppStateChange() {
      final currentLifecycleState = WidgetsBinding.instance.lifecycleState;
      final wasVisible = isScreenVisible.value;
      final isNowVisible = currentLifecycleState == AppLifecycleState.resumed;

      isScreenVisible.value = isNowVisible;

      // 画面が非表示から表示に変わった場合に再読み込み
      if (!wasVisible && isNowVisible) {
        loadStatistics();
      }
    }

    // アプリライフサイクルの監視
    final observer = _LifecycleObserver(onAppStateChange);
    WidgetsBinding.instance.addObserver(observer);

    // 初回読み込み
    loadStatistics();

    return () {
      WidgetsBinding.instance.removeObserver(observer);
    };
  }, []);

  // Widgetが再描画されるたびに統計を更新（タブ切り替え対応）
  useEffect(() {
    // PostFrameCallbackでwidgetの構築完了後に実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadStatistics();
    });
    return null;
  });

  DiveDuration getDiveDuration(int minutes) {
    if (minutes <= 0) return DiveDuration(hour: 0, minute: 0);

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return DiveDuration(hour: hours, minute: remainingMinutes);
  }

  return StatisticsResult(
    isLoading: isLoading.value,
    totalMinutes: totalMinutes.value,
    diveCount: diveCount.value,
    error: error.value,
    diveDuration: getDiveDuration(totalMinutes.value),
  );
}

// ライフサイクル監視用のObserver
class _LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onAppStateChange;

  _LifecycleObserver(this.onAppStateChange);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onAppStateChange();
  }
}
