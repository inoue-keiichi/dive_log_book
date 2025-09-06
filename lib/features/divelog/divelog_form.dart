import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/dive_log.dart';
import 'divelog_form_template.dart';
import 'use_divelog_form.dart';

class DiveLogFormScreen extends HookWidget {
  final DiveLog? diveLog;

  const DiveLogFormScreen({super.key, this.diveLog});

  @override
  Widget build(BuildContext context) {
    // useDivelogFormの返り値を展開
    final (
      :formKey,
      :initilalValue,
      :isLoading,
      :submitHandler,
      :deleteHandler,
    ) = useDivelogForm(context: context, divelog: diveLog);

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
