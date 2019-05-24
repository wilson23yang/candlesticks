
class MACDValueData {
  Map<MACDValueKey,double> _map;

  MACDValueData(){
    _map = <MACDValueKey,double>{};
  }

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

  MACDValueData clone(){
    MACDValueData clone = MACDValueData();
    if(this.containsKey(MACDValueKey.DIF)){
      clone.put(MACDValueKey.DIF, this.get(MACDValueKey.DIF));
    }
    if(this.containsKey(MACDValueKey.DEA)){
      clone.put(MACDValueKey.DEA, this.get(MACDValueKey.DEA));
    }
    if(this.containsKey(MACDValueKey.MACD)){
      clone.put(MACDValueKey.MACD, this.get(MACDValueKey.MACD));
    }
    if(this.containsKey(MACDValueKey.S)){
      clone.put(MACDValueKey.S, this.get(MACDValueKey.S));
    }
    if(this.containsKey(MACDValueKey.L)){
      clone.put(MACDValueKey.L, this.get(MACDValueKey.L));
    }
    if(this.containsKey(MACDValueKey.M)){
      clone.put(MACDValueKey.M, this.get(MACDValueKey.M));
    }
    return clone;
  }


  ///
  MACDValueData operator +(MACDValueData o){
    MACDValueData newData = MACDValueData();
    MACDValueData clone = this.clone();
    if(clone.containsKey(MACDValueKey.DIF) && o.containsKey(MACDValueKey.DIF)){
      newData.put(MACDValueKey.DIF, this.get(MACDValueKey.DIF)+o.get(MACDValueKey.DIF));
    } else {
      newData.put(MACDValueKey.DIF, this.get(MACDValueKey.DIF));
    }
    if(clone.containsKey(MACDValueKey.DEA) && o.containsKey(MACDValueKey.DEA)){
      newData.put(MACDValueKey.DEA, this.get(MACDValueKey.DEA)+o.get(MACDValueKey.DEA));
    } else {
      newData.put(MACDValueKey.DEA, this.get(MACDValueKey.DEA));
    }
    if(clone.containsKey(MACDValueKey.MACD) && o.containsKey(MACDValueKey.MACD)){
      newData.put(MACDValueKey.MACD, this.get(MACDValueKey.MACD)+o.get(MACDValueKey.MACD));
    } else {
      newData.put(MACDValueKey.MACD, this.get(MACDValueKey.MACD));
    }
    if(clone.containsKey(MACDValueKey.S)){
      newData.put(MACDValueKey.S, this.get(MACDValueKey.S));
    }
    if(clone.containsKey(MACDValueKey.L)){
      newData.put(MACDValueKey.L, this.get(MACDValueKey.L));
    }
    if(clone.containsKey(MACDValueKey.M)){
      newData.put(MACDValueKey.M, this.get(MACDValueKey.M));
    }
    return newData;
  }

  ///
  MACDValueData operator -(MACDValueData o){
    MACDValueData newData = MACDValueData();
    MACDValueData clone = this.clone();
    if(clone.containsKey(MACDValueKey.DIF) && o.containsKey(MACDValueKey.DIF)){
      newData.put(MACDValueKey.DIF, this.get(MACDValueKey.DIF)-o.get(MACDValueKey.DIF));
    } else {
      newData.put(MACDValueKey.DIF, this.get(MACDValueKey.DIF));
    }
    if(clone.containsKey(MACDValueKey.DEA) && o.containsKey(MACDValueKey.DEA)){
      newData.put(MACDValueKey.DEA, this.get(MACDValueKey.DEA)-o.get(MACDValueKey.DEA));
    } else {
      newData.put(MACDValueKey.DEA, this.get(MACDValueKey.DEA));
    }
    if(clone.containsKey(MACDValueKey.MACD) && o.containsKey(MACDValueKey.MACD)){
      newData.put(MACDValueKey.MACD, this.get(MACDValueKey.MACD)-o.get(MACDValueKey.MACD));
    } else {
      newData.put(MACDValueKey.MACD, this.get(MACDValueKey.MACD));
    }
    if(clone.containsKey(MACDValueKey.S)){
      newData.put(MACDValueKey.S, this.get(MACDValueKey.S));
    }
    if(clone.containsKey(MACDValueKey.L)){
      newData.put(MACDValueKey.L, this.get(MACDValueKey.L));
    }
    if(clone.containsKey(MACDValueKey.M)){
      newData.put(MACDValueKey.M, this.get(MACDValueKey.M));
    }
    return newData;
  }

  ///
  MACDValueData operator *(double progress){
    MACDValueData newData = MACDValueData();
    MACDValueData clone = this.clone();
    if(clone.containsKey(MACDValueKey.DIF)){
      newData.put(MACDValueKey.DIF, this.get(MACDValueKey.DIF)*progress);
    }
    if(clone.containsKey(MACDValueKey.DEA) ){
      newData.put(MACDValueKey.DEA, this.get(MACDValueKey.DEA)*progress);
    }
    if(clone.containsKey(MACDValueKey.MACD)){
      newData.put(MACDValueKey.MACD, this.get(MACDValueKey.MACD)*progress);
    }
    if(clone.containsKey(MACDValueKey.S)){
      newData.put(MACDValueKey.S, this.get(MACDValueKey.S));
    }
    if(clone.containsKey(MACDValueKey.L)){
      newData.put(MACDValueKey.L, this.get(MACDValueKey.L));
    }
    if(clone.containsKey(MACDValueKey.M)){
      newData.put(MACDValueKey.M, this.get(MACDValueKey.M));
    }
    return newData;
  }
}

enum MACDValueKey{
  DIF,DEA,S,L,M,MACD
}

