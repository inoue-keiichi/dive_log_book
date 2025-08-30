import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/dive_log.dart';
import '../../services/database_service.dart';
import 'divelog_form_template.dart';
import 'form_hooks.dart';

class DiveLogFormScreen extends HookWidget {
  final DiveLog? diveLog;

  const DiveLogFormScreen({super.key, this.diveLog});

  @override
  Widget build(BuildContext context) {
    // React Hooksスタイルで状態を管理
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isLoading = useLoading();
    final databaseService = useMemoized(() => DatabaseService());
    final dateFormat = useDateFormat('yyyy-MM-dd');

    // フォーム送信ハンドラー（新規作成または更新）
    final handleSubmit =
        diveLog == null
            ? useCreateHandler(
              formKey: formKey,
              isLoading: isLoading,
              databaseService: databaseService,
              dateFormat: dateFormat,
              context: context,
            )
            : useUpdateHandler(
              formKey: formKey,
              isLoading: isLoading,
              diveLog: diveLog!, // この時点ではdiveLog != nullなので安全
              databaseService: databaseService,
              dateFormat: dateFormat,
              context: context,
            );

    final divelogInit =
        diveLog == null ? DiveLog(date: DateTime.now()) : diveLog!;

    // UIテンプレートを呼び出し
    return DiveLogFormTemplate(
      formKey: formKey,
      isLoading: isLoading,
      divelog: divelogInit,
      handleSubmit: handleSubmit,
    );
  }
}
