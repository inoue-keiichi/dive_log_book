import 'package:dive_log_book/features/divelog/form_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../models/dive_log.dart';
import '../../utils/date_formatter.dart';

class DiveLogFormTemplate extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final ValueNotifier<bool> isLoading;
  final DiveLog divelog;
  final VoidCallback handleSubmit;
  final VoidCallback? handleDelete;

  const DiveLogFormTemplate({
    super.key,
    required this.formKey,
    required this.isLoading,
    required this.divelog,
    required this.handleSubmit,
    this.handleDelete,
  });

  @override
  Widget build(BuildContext context) {
    // DiveLogをフォーム用の初期値に変換
    final formInitialValues = toMap(divelog);

    return Scaffold(
      appBar: AppBar(
        title: Text(divelog.id == null ? '新規ダイブログ' : 'ダイブログ編集'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 編集時のみ削除ボタンを表示
          if (divelog.id != null && handleDelete != null)
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
                  initialValue: formInitialValues,
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
                        validator: DiveLogValidators.validatePlace,
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
                        validator: DiveLogValidators.validatePoint,
                      ),
                      const SizedBox(height: 16),

                      // 潜水開始時間
                      FormBuilderTextField(
                        name: 'divingStartTime',
                        decoration: const InputDecoration(
                          labelText: '潜水開始時間 (HH:mm)',
                          border: OutlineInputBorder(),
                        ),
                        validator: DiveLogValidators.validateTimeFormat,
                      ),
                      const SizedBox(height: 16),

                      // 潜水終了時間
                      FormBuilderTextField(
                        name: 'divingEndTime',
                        decoration: const InputDecoration(
                          labelText: '潜水終了時間 (HH:mm)',
                          border: OutlineInputBorder(),
                        ),
                        validator: DiveLogValidators.validateTimeFormat,
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
                        validator: DiveLogValidators.validateAverageDepth,
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
                        validator: DiveLogValidators.validateMaxDepth,
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
                        validator: DiveLogValidators.validateTankStartPressure,
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
                        validator: DiveLogValidators.validateTankEndPressure,
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
                        validator: DiveLogValidators.validateWeight,
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
                        validator: DiveLogValidators.validateTemperature,
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
                        validator: DiveLogValidators.validateWaterTemperature,
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
                        validator: DiveLogValidators.validateTransparency,
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
                        validator: DiveLogValidators.validateMemo,
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
                          child: Text(divelog.id == null ? '新規作成' : '上書き'),
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
