import 'package:flutter/material.dart';

class KdjStyle {
  Color kColor;
  int period;

  Color dColor;

  Color jColor;
  Duration duration;
  double cameraPaddingY;

  KdjStyle({this.kColor, this.dColor, this.jColor, this.period, this.cameraPaddingY,this.duration});
}

KdjStyle defaultKdjStyle = KdjStyle(
    cameraPaddingY: 0.2,
    period: 14,
    kColor: Colors.yellowAccent,
    dColor: Colors.greenAccent,
    jColor: Colors.deepPurpleAccent,
    duration: Duration(milliseconds: 200)
);