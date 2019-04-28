
class IndicatorSwitch{

  bool mainSwitch = false;
  bool subSwitch = false;

  bool maSwitch = false;
  bool bollSwitch = false;

  bool macdSwitch = false;
  bool kdjSwitch = false;
  bool rsiSwitch = false;
  bool wrSwitch = false;



  IndicatorSwitch();

}

IndicatorSwitch defaultIndicatorSwitch = IndicatorSwitch();

void setMainSwitch(bool s){//只处理false
  if(!s){
    defaultIndicatorSwitch.mainSwitch = false;
    defaultIndicatorSwitch.maSwitch = false;
    defaultIndicatorSwitch.bollSwitch = false;
  }
}

void setMaSwitch(bool s){//只处理true
  if(s){
    defaultIndicatorSwitch.mainSwitch = true;
    defaultIndicatorSwitch.maSwitch = true;
    defaultIndicatorSwitch.bollSwitch = false;
  }
}

void setBollSwitch(bool s){//只处理true
  if(s){
    defaultIndicatorSwitch.mainSwitch = true;
    defaultIndicatorSwitch.maSwitch = false;
    defaultIndicatorSwitch.bollSwitch = true;
  }
}

///////////////////////////////////////

void setSubSwitch(bool s){//只处理false
  if(!s){
    defaultIndicatorSwitch.subSwitch = false;
    defaultIndicatorSwitch.macdSwitch = false;
    defaultIndicatorSwitch.kdjSwitch = false;
    defaultIndicatorSwitch.rsiSwitch = false;
    defaultIndicatorSwitch.wrSwitch = false;
  }
}

void setMacdSwitch(bool s){//只处理true
  if(s){
    defaultIndicatorSwitch.subSwitch = true;
    defaultIndicatorSwitch.macdSwitch = true;
    defaultIndicatorSwitch.kdjSwitch = false;
    defaultIndicatorSwitch.rsiSwitch = false;
    defaultIndicatorSwitch.wrSwitch = false;
  }
}

void setKdjSwitch(bool s){//只处理true
  if(s){
    defaultIndicatorSwitch.subSwitch = true;
    defaultIndicatorSwitch.macdSwitch = false;
    defaultIndicatorSwitch.kdjSwitch = true;
    defaultIndicatorSwitch.rsiSwitch = false;
    defaultIndicatorSwitch.wrSwitch = false;
  }
}

void setRsiSwitch(bool s){//只处理true
  if(s){
    defaultIndicatorSwitch.subSwitch = true;
    defaultIndicatorSwitch.macdSwitch = false;
    defaultIndicatorSwitch.kdjSwitch = false;
    defaultIndicatorSwitch.rsiSwitch = true;
    defaultIndicatorSwitch.wrSwitch = false;
  }
}

void setWrSwitch(bool s){//只处理true
  if(s){
    defaultIndicatorSwitch.subSwitch = true;
    defaultIndicatorSwitch.macdSwitch = false;
    defaultIndicatorSwitch.kdjSwitch = false;
    defaultIndicatorSwitch.rsiSwitch = false;
    defaultIndicatorSwitch.wrSwitch = true;
  }
}