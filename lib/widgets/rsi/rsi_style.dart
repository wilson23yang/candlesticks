import 'package:flutter/material.dart';

class RsiStyle {
  Color longColor;
  int longPeriod;

  Color middleColor;
  int middlePeriod;

  Color shortColor;
  int shortPeriod;

  Duration duration;

  double cameraPaddingY;

  RsiStyle({this.longColor, this.longPeriod,
    this.middleColor, this.middlePeriod,
    this.shortColor, this.shortPeriod,
    this.duration,  this.cameraPaddingY});
}

RsiStyle defaultRsiStyle = RsiStyle(
    cameraPaddingY: 0.2,
    shortPeriod: 7,
    shortColor: Colors.yellowAccent,
    middlePeriod: 14,
    middleColor: Colors.greenAccent,
    longPeriod: 21,
    longColor: Colors.deepPurpleAccent,
    duration: Duration(milliseconds: 200)
);