
import 'package:candlesticks/widgets/kdj/kdj_view.dart';

class KdjValueData {
  Map<KDJ,double> _map;

  KdjValueData(){
    _map = <KDJ,double>{};
  }

  void put(KDJ key,double value){
    _map[key] = value;
  }

  double get(KDJ key){
    if(containsKey(key)){
      return _map[key];
    }
    return 0;
  }

  ///
  bool containsKey(KDJ key){
    return _map.containsKey(key);
  }

  ///
  void remove(KDJ key){
    if(containsKey(key)){
      _map.remove(key);
    }
  }

  ///
  KdjValueData clone(){
    KdjValueData clone = KdjValueData();
    if(this.containsKey(KDJ.J)){
      clone.put(KDJ.J, this.get(KDJ.J));
    }
    if(this.containsKey(KDJ.D)){
      clone.put(KDJ.D, this.get(KDJ.D));
    }
    if(this.containsKey(KDJ.K)){
      clone.put(KDJ.K, this.get(KDJ.K));
    }
    return clone;
  }


  ///
  KdjValueData operator +(KdjValueData o){
    KdjValueData newData = KdjValueData();
    KdjValueData clone = this.clone();
    if(clone.containsKey(KDJ.J) && o.containsKey(KDJ.J)){
      newData.put(KDJ.J, this.get(KDJ.J)+o.get(KDJ.J));
    } else {
      newData.put(KDJ.J, this.get(KDJ.J));
    }
    if(clone.containsKey(KDJ.D) && o.containsKey(KDJ.D)){
      newData.put(KDJ.D, this.get(KDJ.D)+o.get(KDJ.D));
    } else {
      newData.put(KDJ.D, this.get(KDJ.D));
    }
    if(clone.containsKey(KDJ.K) && o.containsKey(KDJ.K)){
      newData.put(KDJ.K, this.get(KDJ.K)+o.get(KDJ.K));
    } else {
      newData.put(KDJ.K, this.get(KDJ.K));
    }
    return newData;
  }

  ///
  KdjValueData operator -(KdjValueData o){
    KdjValueData newData = KdjValueData();
    KdjValueData clone = this.clone();
    if(clone.containsKey(KDJ.J) && o.containsKey(KDJ.J)){
      newData.put(KDJ.J, this.get(KDJ.J)-o.get(KDJ.J));
    } else {
      newData.put(KDJ.J, this.get(KDJ.J));
    }
    if(clone.containsKey(KDJ.D) && o.containsKey(KDJ.D)){
      newData.put(KDJ.D, this.get(KDJ.D)-o.get(KDJ.D));
    } else {
      newData.put(KDJ.D, this.get(KDJ.D));
    }
    if(clone.containsKey(KDJ.K) && o.containsKey(KDJ.K)){
      newData.put(KDJ.K, this.get(KDJ.K)-o.get(KDJ.K));
    } else {
      newData.put(KDJ.K, this.get(KDJ.K));
    }
    return newData;
  }


  ///
  KdjValueData operator *(double progress){
    KdjValueData newData = KdjValueData();
    KdjValueData clone = this.clone();
    if(clone.containsKey(KDJ.J)){
      newData.put(KDJ.J, this.get(KDJ.J)*progress);
    }
    if(clone.containsKey(KDJ.D) ){
      newData.put(KDJ.D, this.get(KDJ.D)*progress);
    }
    if(clone.containsKey(KDJ.K)){
      newData.put(KDJ.K, this.get(KDJ.K)*progress);
    }
    return newData;
  }
}

