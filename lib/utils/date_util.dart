import 'package:intl/intl.dart';
class DateUtil{

  ///时间戳转为时间字符
  static String toMMddHHmm(int timestamp) {
    var format = DateFormat('MM-dd HH:mm');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return format.format(date);
  }

  ///时间戳转为时间字符
  static String toYMD(int timestamp) {
    var format = DateFormat('yyy-MM-dd');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return format.format(date);
  }

}