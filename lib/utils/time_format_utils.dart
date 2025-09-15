class TimeFormatUtils {
  /// 分数を「XX時間XX分」形式にフォーマット
  static String formatMinutesToDuration(int minutes) {
    if (minutes <= 0) return '0時間0分';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return '${hours}時間${remainingMinutes}分';
  }

  /// HH:mm形式の時間文字列を分数に変換
  static int? parseTimeToMinutes(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(timeString)) return null;

    final parts = timeString.split(':');
    if (parts.length != 2) return null;

    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
        return null;
      }

      return hours * 60 + minutes;
    } catch (e) {
      return null;
    }
  }

  /// 2つの時間文字列間の差を分数で計算
  static int? calculateDurationMinutes(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return null;

    final startMinutes = parseTimeToMinutes(startTime);
    final endMinutes = parseTimeToMinutes(endTime);

    if (startMinutes == null || endMinutes == null) return null;

    final duration = endMinutes - startMinutes;
    return duration >= 0 ? duration : null; // 負の値は無効とする
  }

  /// 時間文字列が有効かどうかを検証
  static bool isValidTimeFormat(String? timeString) {
    return parseTimeToMinutes(timeString) != null;
  }
}