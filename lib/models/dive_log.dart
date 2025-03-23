class DiveLog {
  final int? id;
  final String date;
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

  // データベースから取得したMapからDiveLogオブジェクトを作成
  factory DiveLog.fromMap(Map<String, dynamic> map) {
    return DiveLog(
      id: map['id'],
      date: map['date'],
      place: map['place'],
      point: map['point'],
      divingStartTime: map['divingStartTime'],
      divingEndTime: map['divingEndTime'],
      averageDepth:
          map['averageDepth'] != null ? map['averageDepth'].toDouble() : null,
      maxDepth: map['maxDepth'] != null ? map['maxDepth'].toDouble() : null,
      tankStartPressure:
          map['tankStartPressure'] != null
              ? map['tankStartPressure'].toDouble()
              : null,
      tankEndPressure:
          map['tankEndPressure'] != null
              ? map['tankEndPressure'].toDouble()
              : null,
      tankKind:
          map['tankKind'] != null
              ? TankKind.values.firstWhere(
                (e) => e.toString() == 'TankKind.${map['tankKind']}',
                orElse: () => TankKind.STEEL,
              )
              : null,
      suit:
          map['suit'] != null
              ? Suit.values.firstWhere(
                (e) => e.toString() == 'Suit.${map['suit']}',
                orElse: () => Suit.WET,
              )
              : null,
      weight: map['weight'] != null ? map['weight'].toDouble() : null,
      weather:
          map['weather'] != null
              ? Weather.values.firstWhere(
                (e) => e.toString() == 'Weather.${map['weather']}',
                orElse: () => Weather.SUNNY,
              )
              : null,
      temperature:
          map['temperature'] != null ? map['temperature'].toDouble() : null,
      waterTemperature:
          map['waterTemperature'] != null
              ? map['waterTemperature'].toDouble()
              : null,
      transparency:
          map['transparency'] != null ? map['transparency'].toDouble() : null,
      memo: map['memo'],
    );
  }

  // DiveLogオブジェクトをデータベース保存用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'place': place,
      'point': point,
      'divingStartTime': divingStartTime,
      'divingEndTime': divingEndTime,
      'averageDepth': averageDepth,
      'maxDepth': maxDepth,
      'tankStartPressure': tankStartPressure,
      'tankEndPressure': tankEndPressure,
      'tankKind': tankKind?.name,
      'suit': suit?.name,
      'weight': weight,
      'weather': weather?.name,
      'temperature': temperature,
      'waterTemperature': waterTemperature,
      'transparency': transparency,
      'memo': memo,
    };
  }

  // コピーメソッド
  DiveLog copyWith({
    int? id,
    String? date,
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
