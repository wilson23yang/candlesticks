
class WrValueData {
  Map<int,double> _map = <int,double>{};

  WrValueData();

  void put(int key,double value){
    _map[key] = value;
  }

  double get(int key){
    if(containsKey(key)){
      return _map[key];
    }
    return 0;
  }

  bool containsKey(int key){
    return _map.containsKey(key);
  }
}

