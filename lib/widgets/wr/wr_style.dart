import 'package:flutter/material.dart';

class WrStyle {
  Color longColor;
  int longPeriod;

  Color middleColor;
  int middlePeriod;

  Color shortColor;
  int shortPeriod;

  Duration duration;

  double cameraPaddingY;

  WrStyle({this.longColor, this.longPeriod,
    this.middleColor, this.middlePeriod,
    this.shortColor, this.shortPeriod,
    this.duration,  this.cameraPaddingY});
}

WrStyle defaultWrStyle = WrStyle(
    cameraPaddingY: 0.2,
    shortPeriod: 0,
    shortColor: Colors.yellowAccent,
    middlePeriod: 14,
    middleColor: Colors.greenAccent,
    longPeriod: 0,
    longColor: Colors.deepPurpleAccent,
    duration: Duration(milliseconds: 200)
);