
import 'package:candlesticks/widgets/kdj/kdj_view.dart';

class KdjValueData {
  Map<KDJ,double> _map = <KDJ,double>{};

  KdjValueData();

  void put(KDJ key,double value){
    _map[key] = value;
  }

  double get(KDJ key){
    if(containsKey(key)){
      return _map[key];
    }
    return 0;
  }

  bool containsKey(KDJ key){
    return _map.containsKey(key);
  }
}

