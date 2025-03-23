import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/dive_log.dart';
import '../services/database_service.dart';
import 'dive_log_form_screen.dart';

class DiveLogListScreen extends HookWidget {
  const DiveLogListScreen({Key? key}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(title: const Text('ダイブログ')),
      body:
          isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : diveLogs.value.isEmpty
              ? const Center(child: Text('ダイブログがありません。新規追加してください。'))
              : ListView.builder(
                itemCount: diveLogs.value.length,
                itemBuilder: (context, index) {
                  final diveLog = diveLogs.value[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      title: Text(diveLog.point ?? '名称なし'),
                      subtitle: Text(diveLog.date),
                      onTap: () async {
                        // 詳細・編集画面へ遷移
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    DiveLogFormScreen(diveLog: diveLog),
                          ),
                        );
                        if (result == true) {
                          _loadDiveLogs(databaseService, diveLogs, isLoading);
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          // 削除確認ダイアログ
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('削除の確認'),
                                  content: const Text('このダイブログを削除しますか？'),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('キャンセル'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('削除'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirmed == true && diveLog.id != null) {
                            await databaseService.deleteDiveLog(diveLog.id!);
                            _loadDiveLogs(databaseService, diveLogs, isLoading);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 新規作成画面へ遷移
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiveLogFormScreen()),
          );
          if (result == true) {
            _loadDiveLogs(databaseService, diveLogs, isLoading);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
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
