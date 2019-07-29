import 'package:flutter/material.dart';

class HorizontalLineFloatingStyle {
  Color lineColor;
  Color pointColor;
  Color labelColor;
  Color labelBorderColor;
  Color labelBgColor;
  Color dashLineColor;

  double lineWidth;
  double pointRadius;
  double dashLineWidth;
  double dashLineGap;
  double textSize;

  Color volumeLineColor;
  Color volumeValueTextColor;

  HorizontalLineFloatingStyle({
    this.lineColor = Colors.grey,
    this.pointColor = Colors.white,
    this.labelBgColor =  Colors.black45,
    this.labelBorderColor = const Color(0xFFDCAD0F),
    this.dashLineColor = const Color(0xBBDCAD0F),
    this.labelColor = const Color(0xFFDCAD0F),
    this.volumeLineColor = const Color(0xFF868686),
    this.volumeValueTextColor = Colors.white,
    this.lineWidth = 0.6,
    this.pointRadius = 2,
    this.dashLineGap = 5,
    this.dashLineWidth = 1.2,
    this.textSize = 10
  });
}

HorizontalLineFloatingStyle defaultHLFStyle = HorizontalLineFloatingStyle()
  ..lineWidth = 0.6
  ..pointRadius = 2
  ..lineColor = Colors.grey
  ..pointColor = Colors.white
  ..labelColor = Colors.white.withOpacity(0.7)
  ..dashLineColor = Colors.white.withOpacity(0.5)
  ..labelBorderColor = Colors.white.withOpacity(0.5)
  ..labelBgColor = Colors.black45
  ..dashLineWidth = 1.2
  ..dashLineGap = 5
  ..textSize = 10
  ..volumeLineColor = Color(0xFF868686)
  ..volumeValueTextColor = Colors.white;
