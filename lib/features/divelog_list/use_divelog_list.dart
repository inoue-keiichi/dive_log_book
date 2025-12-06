import 'package:dive_log_book/providers/database_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/dive_log.dart';
import '../divelog/divelog_form.dart';

/// ダイブログリスト画面用のカスタムフック
({
  ValueNotifier<List<DiveLog>> diveLogs,
  ValueNotifier<bool> isLoading,
  VoidCallback Function() onAddPressed,
  void Function(DiveLog) onItemTap,
})
useDivelogList(BuildContext context, DataAccessProvider da) {
  final diveLogs = useState<List<DiveLog>>([]);
  final isLoading = useState<bool>(true);

  // ダイブログの読み込み
  useEffect(() {
    _loadDiveLogs(diveLogs, isLoading, da);
    return null;
  }, []);

  final onAddPressed = useCallback(() {
    return () => _handleAddPressed(context, diveLogs, isLoading, da);
  }, [context]);

  final onItemTap = useCallback((DiveLog diveLog) {
    return _handleItemTap(context, diveLog, diveLogs, isLoading, da);
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
  DataAccessProvider da,
) async {
  isLoading.value = true;
  diveLogs.value = await (await da.createDiveLogRepository()).getDiveLogs();
  isLoading.value = false;
}

// 新規追加ボタン押下時の処理
Future<void> _handleAddPressed(
  BuildContext context,
  ValueNotifier<List<DiveLog>> diveLogs,
  ValueNotifier<bool> isLoading,
  DataAccessProvider da,
) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DiveLogForm()),
  );
  if (result == true) {
    _loadDiveLogs(diveLogs, isLoading, da);
  }
}

// アイテムタップ時の処理
Future<void> _handleItemTap(
  BuildContext context,
  DiveLog diveLog,
  ValueNotifier<List<DiveLog>> diveLogs,
  ValueNotifier<bool> isLoading,
  DataAccessProvider da,
) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DiveLogForm(diveLog: diveLog)),
  );
  if (result == true) {
    _loadDiveLogs(diveLogs, isLoading, da);
  }
}
