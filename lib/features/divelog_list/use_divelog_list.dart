import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/dive_log.dart';
import '../../services/database_service.dart';
import '../divelog/divelog_form.dart';

// ファイルレベルでDatabaseServiceのインスタンスを取得
final _databaseService = DatabaseService();

/// ダイブログリスト画面用のカスタムフック
({
  ValueNotifier<List<DiveLog>> diveLogs,
  ValueNotifier<bool> isLoading,
  VoidCallback Function() onAddPressed,
  void Function(DiveLog) onItemTap,
})
useDivelogList(BuildContext context) {
  final diveLogs = useState<List<DiveLog>>([]);
  final isLoading = useState<bool>(true);

  // ダイブログの読み込み
  useEffect(() {
    _loadDiveLogs(diveLogs, isLoading);
    return null;
  }, []);

  final onAddPressed = useCallback(() {
    return () => _handleAddPressed(context, diveLogs, isLoading);
  }, [context]);

  final onItemTap = useCallback((DiveLog diveLog) {
    return _handleItemTap(context, diveLog, diveLogs, isLoading);
  }, [context]);

  return (
    diveLogs: diveLogs,
    isLoading: isLoading,
    onAddPressed: onAddPressed,
    onItemTap: onItemTap,
  );
}

// ダイブログの読み込み処理
Future<void> _loadDiveLogs(
  ValueNotifier<List<DiveLog>> diveLogs,
  ValueNotifier<bool> isLoading,
) async {
  isLoading.value = true;
  diveLogs.value = await _databaseService.getDiveLogs();
  isLoading.value = false;
}

// 新規追加ボタン押下時の処理
Future<void> _handleAddPressed(
  BuildContext context,
  ValueNotifier<List<DiveLog>> diveLogs,
  ValueNotifier<bool> isLoading,
) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DiveLogForm()),
  );
  if (result == true) {
    _loadDiveLogs(diveLogs, isLoading);
  }
}

// アイテムタップ時の処理
Future<void> _handleItemTap(
  BuildContext context,
  DiveLog diveLog,
  ValueNotifier<List<DiveLog>> diveLogs,
  ValueNotifier<bool> isLoading,
) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DiveLogForm(diveLog: diveLog)),
  );
  if (result == true) {
    _loadDiveLogs(diveLogs, isLoading);
  }
}
