// 数値バリデーション用のカスタムフック
String? validateDouble(
  String? value, {
  double? min,
  double? max,
  String? unit,
}) {
  if (value == null || value.isEmpty) {
    return null; // 未入力はOK
  }
  if (double.tryParse(value) == null) {
    return '数値を入力してください';
  }

  final numValue = double.parse(value);

  if (max != null && numValue > max) {
    return '$max$unit以下の数値を入力してください';
  }

  if (min != null && numValue < min) {
    return '$min$unit以上の数値を入力してください';
  }

  return null;
}

// 時間フォーマットバリデーション用のカスタムフック
String? validateTimeFormat(String? value) {
  if (value == null || value.isEmpty) {
    return null; // 未入力はOK
  }
  if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
    return '時間のフォーマットを HH:mm にしてください';
  }
  return null;
}
