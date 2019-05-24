class BollValueData {
  double currentValue;
  double ubValue;
  double lbValue;
  double bollValue;

  BollValueData({
    this.currentValue = 0,
    this.ubValue = 0,
    this.lbValue = 0,
    this.bollValue = 0,
  });

  ///
  BollValueData clone() {
    BollValueData clone = BollValueData(
      currentValue: this.currentValue,
      ubValue: this.ubValue,
      lbValue: this.lbValue,
      bollValue: this.bollValue,
    );
    return clone;
  }

  ///
  BollValueData operator +(BollValueData o) {
    if(o == null){
      return this.clone();
    }
    BollValueData clone = this.clone();
    BollValueData newData = BollValueData(
      currentValue: clone.currentValue + o.currentValue,
      ubValue: clone.ubValue + o.ubValue,
      lbValue: clone.lbValue + o.lbValue,
      bollValue: clone.bollValue + o.bollValue,
    );
    return newData;
  }

  ///
  BollValueData operator -(BollValueData o) {
    if(o == null){
      return this.clone();
    }
    BollValueData clone = this.clone();
    BollValueData newData = BollValueData(
      currentValue: clone.currentValue - o.currentValue,
      ubValue: clone.ubValue - o.ubValue,
      lbValue: clone.lbValue - o.lbValue,
      bollValue: clone.bollValue - o.bollValue,
    );

    return newData;
  }

  ///
  BollValueData operator *(double progress) {
    BollValueData clone = this.clone();
    BollValueData newData = BollValueData(
      currentValue: clone.currentValue * progress,
      ubValue: clone.ubValue * progress,
      lbValue: clone.lbValue * progress,
      bollValue: clone.bollValue * progress,
    );
    return newData;
  }
}
