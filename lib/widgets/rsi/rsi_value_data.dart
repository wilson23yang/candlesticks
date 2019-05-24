
class RsiValueData {
  Map<int,double> _map;

  RsiValueData(){
    _map = <int,double>{};
  }

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

  void remove(int key){
    if(containsKey(key)){
      _map.remove(key);
    }
  }


  ///
  RsiValueData clone(){
    RsiValueData clone = RsiValueData();
    if(this.containsKey(RsiPeriod.short)){
      clone.put(RsiPeriod.short, this.get(RsiPeriod.short));
    }
    if(this.containsKey(RsiPeriod.long)){
      clone.put(RsiPeriod.long, this.get(RsiPeriod.long));
    }
    if(this.containsKey(RsiPeriod.middle)){
      clone.put(RsiPeriod.middle, this.get(RsiPeriod.middle));
    }
    return clone;
  }


  ///
  RsiValueData operator +(RsiValueData o){
    RsiValueData newData = RsiValueData();
    RsiValueData clone = this.clone();
    if(clone.containsKey(RsiPeriod.short) && o.containsKey(RsiPeriod.short)){
      newData.put(RsiPeriod.short, this.get(RsiPeriod.short)+o.get(RsiPeriod.short));
    } else {
      newData.put(RsiPeriod.short, this.get(RsiPeriod.short));
    }
    if(clone.containsKey(RsiPeriod.middle) && o.containsKey(RsiPeriod.middle)){
      newData.put(RsiPeriod.middle, this.get(RsiPeriod.middle)+o.get(RsiPeriod.middle));
    } else {
      newData.put(RsiPeriod.middle, this.get(RsiPeriod.middle));
    }
    if(clone.containsKey(RsiPeriod.long) && o.containsKey(RsiPeriod.long)){
      newData.put(RsiPeriod.long, this.get(RsiPeriod.long)+o.get(RsiPeriod.long));
    } else {
      newData.put(RsiPeriod.long, this.get(RsiPeriod.long));
    }
    return newData;
  }

  ///
  RsiValueData operator -(RsiValueData o){
    RsiValueData newData = RsiValueData();
    RsiValueData clone = this.clone();
    if(clone.containsKey(RsiPeriod.short) && o.containsKey(RsiPeriod.short)){
      newData.put(RsiPeriod.short, this.get(RsiPeriod.short)-o.get(RsiPeriod.short));
    } else {
      newData.put(RsiPeriod.short, this.get(RsiPeriod.short));
    }
    if(clone.containsKey(RsiPeriod.middle) && o.containsKey(RsiPeriod.middle)){
      newData.put(RsiPeriod.middle, this.get(RsiPeriod.middle)-o.get(RsiPeriod.middle));
    } else {
      newData.put(RsiPeriod.middle, this.get(RsiPeriod.middle));
    }
    if(clone.containsKey(RsiPeriod.long) && o.containsKey(RsiPeriod.long)){
      newData.put(RsiPeriod.long, this.get(RsiPeriod.long)-o.get(RsiPeriod.long));
    } else {
      newData.put(RsiPeriod.long, this.get(RsiPeriod.long));
    }
    return newData;
  }


  ///
  RsiValueData operator *(double progress){
    RsiValueData newData = RsiValueData();
    RsiValueData clone = this.clone();
    if(clone.containsKey(RsiPeriod.short)){
      newData.put(RsiPeriod.short, this.get(RsiPeriod.short)*progress);
    }
    if(clone.containsKey(RsiPeriod.middle) ){
      newData.put(RsiPeriod.middle, this.get(RsiPeriod.middle)*progress);
    }
    if(clone.containsKey(RsiPeriod.long)){
      newData.put(RsiPeriod.long, this.get(RsiPeriod.long)*progress);
    }

    return newData;
  }
}

class RsiPeriod{
  static int short = 7;
  static int middle = 14;
  static int long  = 21;
}

