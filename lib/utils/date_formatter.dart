import 'package:intl/intl.dart';

/// 日付フォーマット関連のユーティリティ関数
class DateFormatter {
  /// yyyy-MM-dd形式の日付フォーマッター
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// DateTimeをyyyy-MM-dd形式の文字列に変換する
  ///
  /// [date] フォーマットするDateTime
  /// 戻り値: yyyy-MM-dd形式の文字列
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// yyyy-MM-dd形式の文字列をDateTimeに変換する
  ///
  /// [dateString] パースする日付文字列
  /// 戻り値: DateTime オブジェクト
  static DateTime parseDate(String dateString) {
    return _dateFormat.parse(dateString);
  }

  /// DateFormatオブジェクトを取得する（既存のコードとの互換性のため）
  ///
  /// 戻り値: yyyy-MM-dd形式のDateFormatオブジェクト
  static DateFormat get dateFormat => _dateFormat;
}
