
class StringUtil{

  static String trimZero(String count, int precision) {
    try{
      while (count.contains('.') &&
          count.endsWith('0') &&
          count.substring(count.lastIndexOf('.')).length > precision + 1) {
        count = count.substring(0, count.length - 1);
      }
      return count;
    }catch(e){
      return '';
    }
  }

  /// 转换资产换算，保留precision位小数
  static String formatAssetNum(var num, int precision) {
    String res = '';
    try{
      if (num is int) {
        res = num.toDouble().toStringAsFixed(precision);
      } else if (num is double) {
        res = num.toStringAsFixed(precision);
      } else if (num is String) {
        res = double.parse(num).toStringAsFixed(precision);
      }
    }catch(_){}
    return res;
  }

  ///将大数据简写成k M
  static String abridge2KM(var t_num){
    double num = 0;
    try{
      if (t_num is int) {
        num = t_num.toDouble();
      } else if (t_num is double) {
        num = t_num;
      } else if (t_num is String) {
        num = double.parse(t_num);
      }
    }catch(_){}

    if(num >= 1000000){
      return '${StringUtil.formatAssetNum(num / 1000000, 2)}M';
    } else if(num >= 1000){
      return '${StringUtil.formatAssetNum(num / 1000, 2)}k';
    } else if(num > 100){
      return '${StringUtil.formatAssetNum(num, 2)}';
    } else if(num > 1){
      return '${StringUtil.formatAssetNum(num, 4)}';
    } else if(num == 0){
      return '${StringUtil.formatAssetNum(num, 2)}';
    } else{
      return '${StringUtil.formatAssetNum(num, 8)}';
    }
  }

  ///提取小数精度
  static int getPrecision(var num,{int defaultPrecision = 2}){
    try{
      String numStr = StringUtil.trimZero(num.toString(), defaultPrecision);
      int precision = defaultPrecision;
      if(numStr is String){
        String str = numStr;
        if(str.contains('.')){
          int p = str.length - str.indexOf('.') - 1;
          if(p < 4){
            p = precision;
          }
          precision = p;
        }
      }
      return precision;
    }catch(e){
      return defaultPrecision;
    }
  }

}