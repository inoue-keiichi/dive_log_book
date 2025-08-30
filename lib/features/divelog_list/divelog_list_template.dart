import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/dive_log.dart';

/// ダイブログリスト画面のUIテンプレート
class DiveLogListTemplate extends StatelessWidget {
  final List<DiveLog> diveLogs;
  final bool isLoading;
  final VoidCallback? onAddPressed;
  final void Function(DiveLog diveLog)? onItemTap;
  final void Function(DiveLog diveLog)? onDeletePressed;

  const DiveLogListTemplate({
    super.key,
    required this.diveLogs,
    required this.isLoading,
    this.onAddPressed,
    this.onItemTap,
    this.onDeletePressed,
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
        subtitle: Text(DateFormat("yyyy-MM-dd").format(diveLog.date)),
        onTap: () => onItemTap?.call(diveLog),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => onDeletePressed?.call(diveLog),
        ),
      ),
    );
  }
}
