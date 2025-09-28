import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../utils/date_formatter.dart';
import '../../validators/validator.dart';

class DiveLogFormTemplate extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final Map<String, dynamic> initilalValue;
  final bool edit;
  final ValueNotifier<bool> isLoading;
  final VoidCallback handleSubmit;
  final VoidCallback? handleDelete;

  const DiveLogFormTemplate({
    super.key,
    required this.formKey,
    required this.initilalValue,
    required this.edit,
    required this.isLoading,
    required this.handleSubmit,
    this.handleDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(edit ? 'ダイブログ編集' : '新規ダイブログ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 編集時のみ削除ボタンを表示
          if (edit && handleDelete != null)
            IconButton(icon: const Icon(Icons.delete), onPressed: handleDelete),
        ],
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
                  initialValue: initilalValue,
                  child: Column(
                    children: [
                      // 日付
                      FormBuilderDateTimePicker(
                        name: 'date',
                        inputType: InputType.date,
                        format: DateFormatter.dateFormat,
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
                        validator: validateTimeFormat,
                      ),
                      const SizedBox(height: 16),

                      // 潜水終了時間
                      FormBuilderTextField(
                        name: 'divingEndTime',
                        decoration: const InputDecoration(
                          labelText: '潜水終了時間 (HH:mm)',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateTimeFormat,
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
                        validator: validateAverageDepth,
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
                        validator: validateMaxDepth,
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
                        validator: validateTankStartPressure,
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
                        validator: validateTankEndPressure,
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
                        validator: validateWeight,
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
                        validator: validateTemperature,
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
                        validator: validateWaterTemperature,
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
                        validator: validateTransparency,
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
                        maxLength: 1023,
                      ),
                      const SizedBox(height: 24),

                      // 送信ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState?.saveAndValidate() ??
                                false) {
                              handleSubmit();
                              Navigator.pop(context, true);
                            }
                          },
                          child: Text(edit ? '上書き' : '新規作成'),
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

// 時間フォーマットバリデーション用の関数
String? validateTimeFormat(String? value) {
  if (value == null || value.isEmpty) {
    return null; // 未入力はOK
  }
  if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
    return '時間のフォーマットを HH:mm にしてください';
  }
  return null;
}

// 水深バリデーション（平均水深用）
String? validateAverageDepth(String? value) {
  return validateDouble(value, min: 0, max: 100, unit: 'm');
}

// 水深バリデーション（最大水深用）
String? validateMaxDepth(String? value) {
  return validateDouble(value, min: 0, max: 200, unit: 'm');
}

// タンク圧力バリデーション（開始圧力用）
String? validateTankStartPressure(String? value) {
  return validateDouble(value, min: 0, max: 300, unit: 'kg/cm²');
}

// タンク圧力バリデーション（終了圧力用）
String? validateTankEndPressure(String? value) {
  return validateDouble(value, min: 0, max: 300, unit: 'kg/cm²');
}

// 重量バリデーション
String? validateWeight(String? value) {
  return validateDouble(value, min: 0, max: 50, unit: 'kg');
}

// 温度バリデーション（気温用）
String? validateTemperature(String? value) {
  return validateDouble(value, min: -50, max: 60, unit: '℃');
}

// 温度バリデーション（水温用）
String? validateWaterTemperature(String? value) {
  return validateDouble(value, min: -5, max: 50, unit: '℃');
}

// 透明度バリデーション
String? validateTransparency(String? value) {
  return validateDouble(value, min: 0, max: 100, unit: 'm');
}
