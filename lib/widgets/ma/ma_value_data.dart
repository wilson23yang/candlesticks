class MaValueData {
  double currentValue;
  double shortValue;
  double middleValue;
  double longValue;

  MaValueData({
    this.currentValue = 0,
    this.shortValue = 0,
    this.middleValue = 0,
    this.longValue = 0,
  });



  ///
  MaValueData clone() {
    MaValueData clone = MaValueData(
      currentValue: this.currentValue,
      shortValue: this.shortValue,
      middleValue: this.middleValue,
      longValue: this.longValue,
    );
    return clone;
  }

  ///
  MaValueData operator +(MaValueData o) {
    if(o == null){
      return this.clone();
    }
    MaValueData clone = this.clone();
    MaValueData newData = MaValueData(
      currentValue: clone.currentValue + o.currentValue,
      shortValue: clone.shortValue + o.shortValue,
      middleValue: clone.middleValue + o.middleValue,
      longValue: clone.longValue + o.longValue,
    );
    return newData;
  }

  ///
  MaValueData operator -(MaValueData o) {
    if(o == null){
      return this.clone();
    }
    MaValueData clone = this.clone();
    MaValueData newData = MaValueData(
      currentValue: clone.currentValue - o.currentValue,
      shortValue: clone.shortValue - o.shortValue,
      middleValue: clone.middleValue - o.middleValue,
      longValue: clone.longValue - o.longValue,
    );

    return newData;
  }

  ///
  MaValueData operator *(double progress) {
    MaValueData clone = this.clone();
    MaValueData newData = MaValueData(
      currentValue: clone.currentValue * progress,
      shortValue: clone.shortValue * progress,
      middleValue: clone.middleValue * progress,
      longValue: clone.longValue * progress,
    );
    return newData;
  }
}
