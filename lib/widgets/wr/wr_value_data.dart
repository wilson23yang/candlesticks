
class WrValueData {
  Map<int,double> _map;


  WrValueData(){
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
  WrValueData clone(){
    WrValueData clone = WrValueData();
    if(this.containsKey(WrPeriod.short)){
      clone.put(WrPeriod.short, this.get(WrPeriod.short));
    }
    if(this.containsKey(WrPeriod.long)){
      clone.put(WrPeriod.long, this.get(WrPeriod.long));
    }
    if(this.containsKey(WrPeriod.middle)){
      clone.put(WrPeriod.middle, this.get(WrPeriod.middle));
    }
    return clone;
  }


  ///
  WrValueData operator +(WrValueData o){
    WrValueData newData = WrValueData();
    WrValueData clone = this.clone();
    if(clone.containsKey(WrPeriod.short) && o.containsKey(WrPeriod.short)){
      newData.put(WrPeriod.short, this.get(WrPeriod.short)+o.get(WrPeriod.short));
    } else {
      newData.put(WrPeriod.short, this.get(WrPeriod.short));
    }
    if(clone.containsKey(WrPeriod.middle) && o.containsKey(WrPeriod.middle)){
      newData.put(WrPeriod.middle, this.get(WrPeriod.middle)+o.get(WrPeriod.middle));
    } else {
      newData.put(WrPeriod.middle, this.get(WrPeriod.middle));
    }
    if(clone.containsKey(WrPeriod.long) && o.containsKey(WrPeriod.long)){
      newData.put(WrPeriod.long, this.get(WrPeriod.long)+o.get(WrPeriod.long));
    } else {
      newData.put(WrPeriod.long, this.get(WrPeriod.long));
    }
    return newData;
  }

  ///
  WrValueData operator -(WrValueData o){
    WrValueData newData = WrValueData();
    WrValueData clone = this.clone();
    if(clone.containsKey(WrPeriod.short) && o.containsKey(WrPeriod.short)){
      newData.put(WrPeriod.short, this.get(WrPeriod.short)-o.get(WrPeriod.short));
    } else {
      newData.put(WrPeriod.short, this.get(WrPeriod.short));
    }
    if(clone.containsKey(WrPeriod.middle) && o.containsKey(WrPeriod.middle)){
      newData.put(WrPeriod.middle, this.get(WrPeriod.middle)-o.get(WrPeriod.middle));
    } else {
      newData.put(WrPeriod.middle, this.get(WrPeriod.middle));
    }
    if(clone.containsKey(WrPeriod.long) && o.containsKey(WrPeriod.long)){
      newData.put(WrPeriod.long, this.get(WrPeriod.long)-o.get(WrPeriod.long));
    } else {
      newData.put(WrPeriod.long, this.get(WrPeriod.long));
    }
    return newData;
  }


  ///
  WrValueData operator *(double progress){
    WrValueData newData = WrValueData();
    WrValueData clone = this.clone();
    if(clone.containsKey(WrPeriod.short)){
      newData.put(WrPeriod.short, this.get(WrPeriod.short)*progress);
    }
    if(clone.containsKey(WrPeriod.middle) ){
      newData.put(WrPeriod.middle, this.get(WrPeriod.middle)*progress);
    }
    if(clone.containsKey(WrPeriod.long)){
      newData.put(WrPeriod.long, this.get(WrPeriod.long)*progress);
    }

    return newData;
  }
}

class WrPeriod{
  static int short = 7;
  static int middle = 14;
  static int long = 21;
}

