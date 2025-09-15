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
