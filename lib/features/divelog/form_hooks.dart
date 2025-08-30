import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../models/dive_log.dart';
import '../../services/database_service.dart';

/// フォームデータからDiveLogオブジェクトを作成するロジック
DiveLog _createDiveLogFromFormData({
  required Map<String, dynamic> formData,
  required DateFormat dateFormat,
  int? existingId,
}) {
  return DiveLog(
    id: existingId,
    date: formData['date'],
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
        formData['weight'] != null && formData['weight'].toString().isNotEmpty
            ? double.parse(formData['weight'].toString())
            : null,
    weather:
        formData['weather'] != null && formData['weather'].toString().isNotEmpty
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
}

// 数値バリデーション用のカスタムフック
String? useNumericValidator(
  String? value, {
  double? min,
  double? max,
  String? minErrorMessage,
  String? maxErrorMessage,
}) {
  if (value == null || value.isEmpty) {
    return null; // 未入力はOK
  }
  if (double.tryParse(value) == null) {
    return '数値を入力してください';
  }

  final numValue = double.parse(value);

  if (max != null && numValue > max) {
    return maxErrorMessage ?? '$max以下の数値を入力してください';
  }

  if (min != null && numValue < min) {
    return minErrorMessage ?? '$min以上の数値を入力してください';
  }

  return null;
}

// 時間フォーマットバリデーション用のカスタムフック
String? useTimeFormatValidator(String? value) {
  if (value == null || value.isEmpty) {
    return null; // 未入力はOK
  }
  if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
    return '時間のフォーマットを HH:mm にしてください';
  }
  return null;
}

// ローディング状態を管理するカスタムフック
ValueNotifier<bool> useLoading() {
  return useState<bool>(false);
}

// 日付フォーマッターを提供するカスタムフック
DateFormat useDateFormat(String format) {
  return useMemoized(() => DateFormat(format), [format]);
}

// ダイブログ作成処理のロジック
VoidCallback useCreateHandler({
  required GlobalKey<FormBuilderState> formKey,
  required ValueNotifier<bool> isLoading,
  required DatabaseService databaseService,
  required DateFormat dateFormat,
  required BuildContext context,
}) {
  return useCallback(() async {
    final formData = formKey.currentState!.value;
    isLoading.value = true;

    final newDiveLog = _createDiveLogFromFormData(
      formData: formData,
      dateFormat: dateFormat,
      existingId: null, // 新規作成時はIDなし
    );

    try {
      await databaseService.insertDiveLog(newDiveLog);
    } finally {
      isLoading.value = false;
    }
  }, [formKey, isLoading, databaseService, dateFormat, context]);
}

// ダイブログ更新処理のロジック
VoidCallback useUpdateHandler({
  required GlobalKey<FormBuilderState> formKey,
  required ValueNotifier<bool> isLoading,
  required DiveLog diveLog,
  required DatabaseService databaseService,
  required DateFormat dateFormat,
  required BuildContext context,
}) {
  return useCallback(() async {
    final formData = formKey.currentState!.value;
    isLoading.value = true;

    final updatedDiveLog = _createDiveLogFromFormData(
      formData: formData,
      dateFormat: dateFormat,
      existingId: diveLog.id, // 既存のIDを使用
    );

    try {
      await databaseService.updateDiveLog(updatedDiveLog);
    } finally {
      isLoading.value = false;
    }
  }, [formKey, isLoading, diveLog, databaseService, dateFormat, context]);
}
