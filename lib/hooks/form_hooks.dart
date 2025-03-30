import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../models/dive_log.dart';
import '../services/database_service.dart';

// フォーム送信ハンドラーのカスタムフック
VoidCallback useSubmitHandler({
  required GlobalKey<FormBuilderState> formKey,
  required ValueNotifier<bool> isLoading,
  required DiveLog? diveLog,
  required DatabaseService databaseService,
  required DateFormat dateFormat,
  required BuildContext context,
}) {
  return useCallback(() async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final formData = formKey.currentState!.value;
      isLoading.value = true;

      // フォームデータからDiveLogオブジェクトを作成
      final newDiveLog = DiveLog(
        id: diveLog?.id,
        date:
            formData['date'] is DateTime
                ? dateFormat.format(formData['date'] as DateTime)
                : formData['date'] as String,
        place: formData['place'] as String?,
        point: formData['point'] as String?,
        divingStartTime: formData['divingStartTime'] as String?,
        divingEndTime: formData['divingEndTime'] as String?,
        averageDepth:
            formData['averageDepth'] != null &&
                    formData['averageDepth'].toString().isNotEmpty
                ? double.parse(formData['averageDepth'].toString())
                : null,
        maxDepth:
            formData['maxDepth'] != null &&
                    formData['maxDepth'].toString().isNotEmpty
                ? double.parse(formData['maxDepth'].toString())
                : null,
        tankStartPressure:
            formData['tankStartPressure'] != null &&
                    formData['tankStartPressure'].toString().isNotEmpty
                ? double.parse(formData['tankStartPressure'].toString())
                : null,
        tankEndPressure:
            formData['tankEndPressure'] != null &&
                    formData['tankEndPressure'].toString().isNotEmpty
                ? double.parse(formData['tankEndPressure'].toString())
                : null,
        tankKind:
            formData['tankKind'] != null &&
                    formData['tankKind'].toString().isNotEmpty
                ? TankKind.values.firstWhere(
                  (e) => e.name == formData['tankKind'],
                  orElse: () => TankKind.STEEL,
                )
                : null,
        suit:
            formData['suit'] != null && formData['suit'].toString().isNotEmpty
                ? Suit.values.firstWhere(
                  (e) => e.name == formData['suit'],
                  orElse: () => Suit.WET,
                )
                : null,
        weight:
            formData['weight'] != null &&
                    formData['weight'].toString().isNotEmpty
                ? double.parse(formData['weight'].toString())
                : null,
        weather:
            formData['weather'] != null &&
                    formData['weather'].toString().isNotEmpty
                ? Weather.values.firstWhere(
                  (e) => e.name == formData['weather'],
                  orElse: () => Weather.SUNNY,
                )
                : null,
        temperature:
            formData['temperature'] != null &&
                    formData['temperature'].toString().isNotEmpty
                ? double.parse(formData['temperature'].toString())
                : null,
        waterTemperature:
            formData['waterTemperature'] != null &&
                    formData['waterTemperature'].toString().isNotEmpty
                ? double.parse(formData['waterTemperature'].toString())
                : null,
        transparency:
            formData['transparency'] != null &&
                    formData['transparency'].toString().isNotEmpty
                ? double.parse(formData['transparency'].toString())
                : null,
        memo: formData['memo'] as String?,
      );

      try {
        if (diveLog == null) {
          // 新規作成
          await databaseService.insertDiveLog(newDiveLog);
        } else {
          // 更新
          await databaseService.updateDiveLog(newDiveLog);
        }
        isLoading.value = false;
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        isLoading.value = false;
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
        }
      }
    }
  }, [formKey, isLoading, diveLog, databaseService, dateFormat, context]);
}
