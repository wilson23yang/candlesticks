
class MACDValueData {
  Map<MACDValueKey,double> _map = <MACDValueKey,double>{};

  MACDValueData();

  void put(MACDValueKey key,double value){
    _map[key] = value;
  }

  double get(MACDValueKey key){
    if(containsKey(key)){
      return _map[key];
    }
    return 0;
  }

  bool containsKey(MACDValueKey key){
    return _map.containsKey(key);
  }

  void remove(MACDValueKey key){
    if(containsKey(key)){
      _map.remove(key);
    }
  }
}

enum MACDValueKey{
  DIF,DEA,S,L,M,MACD
}

