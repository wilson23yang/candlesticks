import 'package:flutter/material.dart';

class MHStyle {
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

  MHStyle({
    this.lineColor = Colors.grey,
    this.pointColor = Colors.white,
    this.labelBgColor =  Colors.black45,
    this.labelBorderColor = const Color(0xFFDCAD0F),
    this.dashLineColor = const Color(0xBBDCAD0F),
    this.labelColor = const Color(0xFFDCAD0F),
    this.lineWidth = 0.6,
    this.pointRadius = 2,
    this.dashLineGap = 5,
    this.dashLineWidth = 1.2,
    this.textSize = 10
  });
}

MHStyle defaultMHStyle = MHStyle()
  ..lineWidth = 0.6
  ..pointRadius = 2
  ..lineColor = Colors.grey
  ..pointColor = Colors.white
  ..labelColor = Color(0xFFDCAD0F)
  ..dashLineColor = Color(0xFFDCAD0F).withOpacity(0.8)
  ..labelBorderColor = Color(0xFFDCAD0F)
  ..labelBgColor = Colors.black45
  ..dashLineWidth = 1.2
  ..dashLineGap = 5
  ..textSize = 10;
