import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/dive_log.dart';
import '../../providers/database_service_provider.dart';
import 'divelog_form_template.dart';
import 'use_divelog_form.dart';

class DiveLogForm extends HookConsumerWidget {
  final DiveLog? diveLog;

  const DiveLogForm({super.key, this.diveLog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final da = ref.watch(dataAccessProvider);

    // useDivelogFormの返り値を展開
    final (
      :formKey,
      :initilalValue,
      :isLoading,
      :submitHandler,
      :deleteHandler,
    ) = useDivelogForm(context, da, diveLog);

    // UIテンプレートを呼び出し
    return DiveLogFormTemplate(
      formKey: formKey,
      isLoading: isLoading,
      edit: diveLog != null,
      initilalValue: initilalValue,
      handleSubmit: submitHandler,
      handleDelete: deleteHandler,
    );
  }
}
