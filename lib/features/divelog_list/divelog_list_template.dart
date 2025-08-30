import 'package:flutter/material.dart';

import '../../models/dive_log.dart';
import '../../utils/date_formatter.dart';

/// ダイブログリスト画面のUIテンプレート
class DiveLogListTemplate extends StatelessWidget {
  final List<DiveLog> diveLogs;
  final bool isLoading;
  final VoidCallback? onAddPressed;
  final void Function(DiveLog diveLog)? onItemTap;

  const DiveLogListTemplate({
    super.key,
    required this.diveLogs,
    required this.isLoading,
    this.onAddPressed,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ダイブログ')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddPressed,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diveLogs.isEmpty) {
      return const Center(child: Text('ダイブログがありません。新規追加してください。'));
    }

    return ListView.builder(
      itemCount: diveLogs.length,
      itemBuilder: (context, index) {
        final diveLog = diveLogs[index];
        return _buildDiveLogCard(context, diveLog);
      },
    );
  }

  Widget _buildDiveLogCard(BuildContext context, DiveLog diveLog) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(diveLog.point ?? ''),
        subtitle: Text(DateFormatter.formatDate(diveLog.date)),
        onTap: () => onItemTap?.call(diveLog),
      ),
    );
  }
}
