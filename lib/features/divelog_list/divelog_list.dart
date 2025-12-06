import 'package:dive_log_book/providers/database_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'divelog_list_template.dart';
import 'use_divelog_list.dart';

// final dbProvider = FutureProvider((ref) {
//   var dbService=DatabaseService(false);
//   return dbService.open();
// });

class DivelogList extends HookConsumerWidget {
  const DivelogList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final da = ref.watch(dataAccessProvider);

    // useDivelogListの返り値を展開
    final (:diveLogs, :isLoading, :onAddPressed, :onItemTap) = useDivelogList(
      context,
      da,
    );

    // UIテンプレートを呼び出し
    return DiveLogListTemplate(
      diveLogs: diveLogs.value,
      isLoading: isLoading.value,
      onAddPressed: onAddPressed(),
      onItemTap: onItemTap,
    );
  }
}
