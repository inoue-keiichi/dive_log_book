import 'package:dive_log_book/validators/validator.dart';

class DiveLog {
  final int? id;
  final DateTime date;
  final String? place;
  final String? point;
  final String? divingStartTime;
  final String? divingEndTime;
  final double? averageDepth;
  final double? maxDepth;
  final double? tankStartPressure;
  final double? tankEndPressure;
  final TankKind? tankKind;
  final Suit? suit;
  final double? weight;
  final Weather? weather;
  final double? temperature;
  final double? waterTemperature;
  final double? transparency;
  final String? memo;

  DiveLog({
    this.id,
    required this.date,
    this.place,
    this.point,
    this.divingStartTime,
    this.divingEndTime,
    this.averageDepth,
    this.maxDepth,
    this.tankStartPressure,
    this.tankEndPressure,
    this.tankKind,
    this.suit,
    this.weight,
    this.weather,
    this.temperature,
    this.waterTemperature,
    this.transparency,
    this.memo,
  });

  // コピーメソッド
  DiveLog copyWith({
    int? id,
    DateTime? date,
    String? place,
    String? point,
    String? divingStartTime,
    String? divingEndTime,
    double? averageDepth,
    double? maxDepth,
    double? tankStartPressure,
    double? tankEndPressure,
    TankKind? tankKind,
    Suit? suit,
    double? weight,
    Weather? weather,
    double? temperature,
    double? waterTemperature,
    double? transparency,
    String? memo,
  }) {
    return DiveLog(
      id: id ?? this.id,
      date: date ?? this.date,
      place: place ?? this.place,
      point: point ?? this.point,
      divingStartTime: divingStartTime ?? this.divingStartTime,
      divingEndTime: divingEndTime ?? this.divingEndTime,
      averageDepth: averageDepth ?? this.averageDepth,
      maxDepth: maxDepth ?? this.maxDepth,
      tankStartPressure: tankStartPressure ?? this.tankStartPressure,
      tankEndPressure: tankEndPressure ?? this.tankEndPressure,
      tankKind: tankKind ?? this.tankKind,
      suit: suit ?? this.suit,
      weight: weight ?? this.weight,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      waterTemperature: waterTemperature ?? this.waterTemperature,
      transparency: transparency ?? this.transparency,
      memo: memo ?? this.memo,
    );
  }
}

enum TankKind { STEEL, ALUMINUM }

enum Suit { WET, DRY }

enum Weather { SUNNY, SUNNY_CLOUDY, CLOUDY, RAINY, SNOWY }

extension DiveLogValidators on DiveLog {
  // 時間フォーマットバリデーション用のメソッド
  static String? validateTimeFormat(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 未入力はOK
    }
    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
      return '時間のフォーマットを HH:mm にしてください';
    }
    return null;
  }

  // 水深バリデーション（平均水深用）
  static String? validateAverageDepth(String? value) {
    return validateDouble(value, min: 0, max: 100, unit: 'm');
  }

  // 水深バリデーション（最大水深用）
  static String? validateMaxDepth(String? value) {
    return validateDouble(value, min: 0, max: 200, unit: 'm');
  }

  // タンク圧力バリデーション（開始圧力用）
  static String? validateTankStartPressure(String? value) {
    return validateDouble(value, min: 0, max: 300, unit: 'kg/cm²');
  }

  // タンク圧力バリデーション（終了圧力用）
  static String? validateTankEndPressure(String? value) {
    return validateDouble(value, min: 0, max: 300, unit: 'kg/cm²');
  }

  // 重量バリデーション
  static String? validateWeight(String? value) {
    return validateDouble(value, min: 0, max: 50, unit: 'kg');
  }

  // 温度バリデーション（気温用）
  static String? validateTemperature(String? value) {
    return validateDouble(value, min: -50, max: 60, unit: '℃');
  }

  // 温度バリデーション（水温用）
  static String? validateWaterTemperature(String? value) {
    return validateDouble(value, min: -5, max: 50, unit: '℃');
  }

  // 透明度バリデーション
  static String? validateTransparency(String? value) {
    return validateDouble(value, min: 0, max: 100, unit: 'm');
  }

  // 場所名バリデーション
  static String? validatePlace(String? value) {
    if (value != null && value.length > 100) {
      return '場所名は100文字以下で入力してください';
    }
    return null;
  }

  // ポイント名バリデーション
  static String? validatePoint(String? value) {
    if (value != null && value.length > 100) {
      return 'ポイント名は100文字以下で入力してください';
    }
    return null;
  }

  // メモバリデーション
  static String? validateMemo(String? value) {
    if (value != null && value.length > 1000) {
      return 'メモは1000文字以下で入力してください';
    }
    return null;
  }
}
