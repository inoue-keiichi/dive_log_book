import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../models/dive_log.dart';
import '../services/database_service.dart';

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

class DiveLogFormScreen extends HookWidget {
  final DiveLog? diveLog;

  const DiveLogFormScreen({Key? key, this.diveLog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // React Hooksスタイルで状態を管理
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isLoading = useLoading();
    final databaseService = useMemoized(() => DatabaseService());
    final dateFormat = useDateFormat('yyyy-MM-dd');

    // 初期値を計算
    final initialValues = useMemoized(
      () => {
        'date':
            diveLog?.date != null
                ? DateTime.parse(diveLog!.date)
                : DateTime.now(),
        'place': diveLog?.place ?? '',
        'point': diveLog?.point ?? '',
        'divingStartTime': diveLog?.divingStartTime ?? '',
        'divingEndTime': diveLog?.divingEndTime ?? '',
        'averageDepth': diveLog?.averageDepth?.toString() ?? '',
        'maxDepth': diveLog?.maxDepth?.toString() ?? '',
        'tankStartPressure': diveLog?.tankStartPressure?.toString() ?? '',
        'tankEndPressure': diveLog?.tankEndPressure?.toString() ?? '',
        'tankKind': diveLog?.tankKind?.name ?? '',
        'suit': diveLog?.suit?.name ?? '',
        'weight': diveLog?.weight?.toString() ?? '',
        'weather': diveLog?.weather?.name ?? '',
        'temperature': diveLog?.temperature?.toString() ?? '',
        'waterTemperature': diveLog?.waterTemperature?.toString() ?? '',
        'transparency': diveLog?.transparency?.toString() ?? '',
        'memo': diveLog?.memo ?? '',
      },
      [diveLog],
    );

    // フォーム送信ハンドラー
    final handleSubmit = useSubmitHandler(
      formKey: formKey,
      isLoading: isLoading,
      diveLog: diveLog,
      databaseService: databaseService,
      dateFormat: dateFormat,
      context: context,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(diveLog == null ? '新規ダイブログ' : 'ダイブログ編集'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, loading, _) {
          return loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValues,
                  child: Column(
                    children: [
                      // 日付
                      FormBuilderDateTimePicker(
                        name: 'date',
                        inputType: InputType.date,
                        format: DateFormat('yyyy-MM-dd'),
                        decoration: const InputDecoration(
                          labelText: '日付',
                          border: OutlineInputBorder(),
                        ),
                        // 日付は必須だが、デフォルト値があるので実質的に常に入力されている
                      ),
                      const SizedBox(height: 16),

                      // 場所
                      FormBuilderTextField(
                        name: 'place',
                        decoration: const InputDecoration(
                          labelText: '場所',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 63,
                      ),
                      const SizedBox(height: 16),

                      // ポイント
                      FormBuilderTextField(
                        name: 'point',
                        decoration: const InputDecoration(
                          labelText: 'ポイント',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 63,
                      ),
                      const SizedBox(height: 16),

                      // 潜水開始時間
                      FormBuilderTextField(
                        name: 'divingStartTime',
                        decoration: const InputDecoration(
                          labelText: '潜水開始時間 (HH:mm)',
                          border: OutlineInputBorder(),
                        ),
                        validator: useTimeFormatValidator,
                      ),
                      const SizedBox(height: 16),

                      // 潜水終了時間
                      FormBuilderTextField(
                        name: 'divingEndTime',
                        decoration: const InputDecoration(
                          labelText: '潜水終了時間 (HH:mm)',
                          border: OutlineInputBorder(),
                        ),
                        validator: useTimeFormatValidator,
                      ),
                      const SizedBox(height: 16),

                      // 平均水深
                      FormBuilderTextField(
                        name: 'averageDepth',
                        decoration: const InputDecoration(
                          labelText: '平均水深 (m)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                useNumericValidator(value, min: 0, max: 100),
                      ),
                      const SizedBox(height: 16),

                      // 最大水深
                      FormBuilderTextField(
                        name: 'maxDepth',
                        decoration: const InputDecoration(
                          labelText: '最大水深 (m)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                useNumericValidator(value, min: 0, max: 100),
                      ),
                      const SizedBox(height: 16),

                      // タンク圧力(開始)
                      FormBuilderTextField(
                        name: 'tankStartPressure',
                        decoration: const InputDecoration(
                          labelText: 'タンク圧力(開始) (kg/cm²)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                useNumericValidator(value, min: 0, max: 500),
                      ),
                      const SizedBox(height: 16),

                      // タンク圧力(終了)
                      FormBuilderTextField(
                        name: 'tankEndPressure',
                        decoration: const InputDecoration(
                          labelText: 'タンク圧力(終了) (kg/cm²)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                useNumericValidator(value, min: 0, max: 500),
                      ),
                      const SizedBox(height: 16),

                      // タンク種類
                      FormBuilderRadioGroup(
                        name: 'tankKind',
                        decoration: const InputDecoration(
                          labelText: 'タンク',
                          border: OutlineInputBorder(),
                        ),
                        options: const [
                          FormBuilderFieldOption(
                            value: 'STEEL',
                            child: Text('スチール'),
                          ),
                          FormBuilderFieldOption(
                            value: 'ALUMINUM',
                            child: Text('アルミニウム'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ウェイト
                      FormBuilderTextField(
                        name: 'weight',
                        decoration: const InputDecoration(
                          labelText: 'ウェイト (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                useNumericValidator(value, min: 0, max: 50),
                      ),
                      const SizedBox(height: 16),

                      // スーツ
                      FormBuilderRadioGroup(
                        name: 'suit',
                        decoration: const InputDecoration(
                          labelText: 'スーツ',
                          border: OutlineInputBorder(),
                        ),
                        options: const [
                          FormBuilderFieldOption(
                            value: 'WET',
                            child: Text('ウェット'),
                          ),
                          FormBuilderFieldOption(
                            value: 'DRY',
                            child: Text('ドライ'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 天気
                      FormBuilderRadioGroup(
                        name: 'weather',
                        decoration: const InputDecoration(
                          labelText: '天気',
                          border: OutlineInputBorder(),
                        ),
                        options: const [
                          FormBuilderFieldOption(
                            value: 'SUNNY',
                            child: Text('晴れ'),
                          ),
                          FormBuilderFieldOption(
                            value: 'SUNNY_CLOUDY',
                            child: Text('晴れ/曇り'),
                          ),
                          FormBuilderFieldOption(
                            value: 'CLOUDY',
                            child: Text('曇り'),
                          ),
                          FormBuilderFieldOption(
                            value: 'RAINY',
                            child: Text('雨'),
                          ),
                          FormBuilderFieldOption(
                            value: 'SNOWY',
                            child: Text('雪'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 気温
                      FormBuilderTextField(
                        name: 'temperature',
                        decoration: const InputDecoration(
                          labelText: '気温 (℃)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                useNumericValidator(value, min: -100, max: 100),
                      ),
                      const SizedBox(height: 16),

                      // 水温
                      FormBuilderTextField(
                        name: 'waterTemperature',
                        decoration: const InputDecoration(
                          labelText: '水温 (℃)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                useNumericValidator(value, min: -10, max: 50),
                      ),
                      const SizedBox(height: 16),

                      // 透明度
                      FormBuilderTextField(
                        name: 'transparency',
                        decoration: const InputDecoration(
                          labelText: '透明度 (m)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => useNumericValidator(
                              value,
                              min: 0,
                              max: 50,
                              minErrorMessage: '0以上の数値を入力してください',
                              maxErrorMessage: '50以下の数値を入力してください',
                            ),
                      ),
                      const SizedBox(height: 16),

                      // メモ
                      FormBuilderTextField(
                        name: 'memo',
                        decoration: const InputDecoration(
                          labelText: 'メモ',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        maxLength: 511,
                      ),
                      const SizedBox(height: 24),

                      // 送信ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            handleSubmit();
                            Navigator.pop(context, true);
                          },
                          child: Text(diveLog == null ? '追加' : '上書き'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}

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
