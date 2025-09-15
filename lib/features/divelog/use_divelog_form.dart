import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/dive_log.dart';
import '../../repositories/divelog.dart';

// ファイルレベルでDiveLogRepositoryのインスタンスを取得
final _diveLogRepository = DiveLogRepository();

/// フォームデータからDiveLogオブジェクトを作成するロジック
DiveLog _createDiveLogFromFormData({
  required Map<String, dynamic> formData,
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

Map<String, dynamic> _toMap(DiveLog? diveLog) {
  if (diveLog == null) {
    return {};
  }

  return {
    'id': diveLog.id,
    'date': diveLog.date,
    'place': diveLog.place,
    'point': diveLog.point,
    'divingStartTime': diveLog.divingStartTime,
    'divingEndTime': diveLog.divingEndTime,
    'averageDepth': diveLog.averageDepth?.toString(),
    'maxDepth': diveLog.maxDepth?.toString(),
    'tankStartPressure': diveLog.tankStartPressure?.toString(),
    'tankEndPressure': diveLog.tankEndPressure?.toString(),
    'tankKind': diveLog.tankKind?.name,
    'suit': diveLog.suit?.name,
    'weight': diveLog.weight?.toString(),
    'weather': diveLog.weather?.name,
    'temperature': diveLog.temperature?.toString(),
    'waterTemperature': diveLog.waterTemperature?.toString(),
    'transparency': diveLog.transparency?.toString(),
    'memo': diveLog.memo,
  };
}

// フォーム関連のフックをまとめて返すカスタムフック
({
  GlobalKey<FormBuilderState> formKey,
  Map<String, dynamic> initilalValue,
  ValueNotifier<bool> isLoading,
  VoidCallback submitHandler,
  VoidCallback deleteHandler,
})
useDivelogForm({required BuildContext context, DiveLog? divelog}) {
  final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
  final isLoading = useState<bool>(false);

  final diveLogId = divelog?.id;
  final submitHandler =
      diveLogId == null
          ? _useCreateHandler(formKey: formKey, isLoading: isLoading)
          : _useUpdateHandler(
            formKey: formKey,
            isLoading: isLoading,
            diveLogId: diveLogId,
          );

  final deleteHandler = _useDeleteHandler(
    diveLogId: diveLogId,
    context: context,
  );

  final divelogInit = divelog ?? DiveLog(date: DateTime.now());

  return (
    formKey: formKey,
    initilalValue: _toMap(divelogInit),
    isLoading: isLoading,
    submitHandler: submitHandler,
    deleteHandler: deleteHandler,
  );
}

// ダイブログ作成処理のロジック
VoidCallback _useCreateHandler({
  required GlobalKey<FormBuilderState> formKey,
  required ValueNotifier<bool> isLoading,
}) {
  return useCallback(() async {
    final formData = formKey.currentState!.value;
    isLoading.value = true;

    final newDiveLog = _createDiveLogFromFormData(
      formData: formData,
      existingId: null, // 新規作成時はIDなし
    );

    try {
      await _diveLogRepository.insertDiveLog(newDiveLog);
    } finally {
      isLoading.value = false;
    }
  }, [formKey, isLoading]);
}

// ダイブログ更新処理のロジック
VoidCallback _useUpdateHandler({
  required GlobalKey<FormBuilderState> formKey,
  required ValueNotifier<bool> isLoading,
  required int diveLogId,
}) {
  return useCallback(() async {
    final formData = formKey.currentState!.value;
    isLoading.value = true;

    final updatedDiveLog = _createDiveLogFromFormData(
      formData: formData,
      existingId: diveLogId, // 既存のIDを使用
    );

    try {
      await _diveLogRepository.updateDiveLog(updatedDiveLog);
    } finally {
      isLoading.value = false;
    }
  }, [formKey, isLoading, diveLogId]);
}

// ダイブログ削除処理のロジック
VoidCallback _useDeleteHandler({
  required int? diveLogId,
  required BuildContext context,
}) {
  return useCallback(() async {
    // 削除確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('削除の確認'),
            content: const Text('このダイブログを削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('削除'),
              ),
            ],
          ),
    );

    if (confirmed == true && diveLogId != null) {
      try {
        await _diveLogRepository.deleteDiveLog(diveLogId);
        // 削除成功時はリストに戻る
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        // エラーハンドリング
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('削除に失敗しました')));
        }
      }
    }
  }, [context]);
}
