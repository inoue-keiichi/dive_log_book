import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/dive_log.dart';
import '../../services/database_service.dart';
import '../divelog/divelog_form.dart';
import 'divelog_list_template.dart';

class DivelogListScreen extends HookWidget {
  const DivelogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diveLogs = useState<List<DiveLog>>([]);
    final isLoading = useState<bool>(true);
    final databaseService = DatabaseService();

    // ダイブログの読み込み
    useEffect(() {
      _loadDiveLogs(databaseService, diveLogs, isLoading);
      return null;
    }, []);

    return DiveLogListTemplate(
      diveLogs: diveLogs.value,
      isLoading: isLoading.value,
      onAddPressed:
          () =>
              _handleAddPressed(context, databaseService, diveLogs, isLoading),
      onItemTap:
          (diveLog) => _handleItemTap(
            context,
            diveLog,
            databaseService,
            diveLogs,
            isLoading,
          ),
      onDeletePressed:
          (diveLog) => _handleDeletePressed(
            context,
            diveLog,
            databaseService,
            diveLogs,
            isLoading,
          ),
    );
  }

  // イベントハンドラーメソッド
  Future<void> _handleAddPressed(
    BuildContext context,
    DatabaseService databaseService,
    ValueNotifier<List<DiveLog>> diveLogs,
    ValueNotifier<bool> isLoading,
  ) async {
    // 新規作成画面へ遷移
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiveLogFormScreen()),
    );
    if (result == true) {
      _loadDiveLogs(databaseService, diveLogs, isLoading);
    }
  }

  Future<void> _handleItemTap(
    BuildContext context,
    DiveLog diveLog,
    DatabaseService databaseService,
    ValueNotifier<List<DiveLog>> diveLogs,
    ValueNotifier<bool> isLoading,
  ) async {
    // 詳細・編集画面へ遷移
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiveLogFormScreen(diveLog: diveLog),
      ),
    );
    if (result == true) {
      _loadDiveLogs(databaseService, diveLogs, isLoading);
    }
  }

  Future<void> _handleDeletePressed(
    BuildContext context,
    DiveLog diveLog,
    DatabaseService databaseService,
    ValueNotifier<List<DiveLog>> diveLogs,
    ValueNotifier<bool> isLoading,
  ) async {
    // 削除確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('削除の確認'),
            content: const Text('このダイブログを削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('削除'),
              ),
            ],
          ),
    );

    if (confirmed == true && diveLog.id != null) {
      await databaseService.deleteDiveLog(diveLog.id!);
      _loadDiveLogs(databaseService, diveLogs, isLoading);
    }
  }

  Future<void> _loadDiveLogs(
    DatabaseService databaseService,
    ValueNotifier<List<DiveLog>> diveLogs,
    ValueNotifier<bool> isLoading,
  ) async {
    isLoading.value = true;
    diveLogs.value = await databaseService.getDiveLogs();
    isLoading.value = false;
  }
}
