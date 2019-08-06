import 'package:flutter/material.dart';

const double DefaultMinWidth = 60;

class KlineFloatingStyle {
  final Color textColor;
  final Color lineColor;
  final Color textBgColor;
  final double textSize;

  KlineFloatingStyle({this.textColor, this.lineColor, this.textSize,this.textBgColor,});
}


KlineFloatingStyle defaultKlineFloatingStyle = KlineFloatingStyle(
  textColor: Colors.white.withOpacity(1.0),
  textBgColor: Colors.black87,
  lineColor: Colors.white.withOpacity(0.9),
  textSize: 11,
);
