import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'divelog_list_template.dart';
import 'use_divelog_list.dart';

class DivelogList extends HookWidget {
  const DivelogList({super.key});

  @override
  Widget build(BuildContext context) {
    // useDivelogListの返り値を展開
    final (:diveLogs, :isLoading, :onAddPressed, :onItemTap) = useDivelogList(
      context,
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
