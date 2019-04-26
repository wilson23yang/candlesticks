import 'package:flutter/material.dart';
import 'dart:math';

class CanvasUtil{
  static void drawDash(Canvas canvas,Size size, Paint paint,Offset p1,Offset p2,double gap){
    Path path = Path();
    if(p1.dx == p2.dx && p1.dy == p2.dy){
      return ;
    }
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double dxy = sqrt(dx * dx + dy * dy);

    if(dxy <= gap){
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      canvas.drawPath(path, paint);
      return;
    }
    double g_dx = gap * dx / dxy;
    double g_dy = gap * dy / dxy;
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p1.dx + g_dx/3, p1.dy+g_dy/3);
    canvas.drawPath(path, paint);

    int count = dxy ~/ (2 * gap);
    for(int i  = 0;i <= count;i++){
      Path p = Path();
      double n1_dx = p1.dx + 2 * g_dx * i;
      double n1_dy = p1.dy + 2 * g_dy * i;
      p.moveTo(n1_dx, n1_dy);

      double n2_dx = p1.dx + 2 * g_dx * i + g_dx;
      double n2_dy = p1.dy + 2 * g_dy * i + g_dy;

      if((n2_dx - p1.dx).abs() > (p2.dx - p1.dx).abs() || (n2_dy - p1.dy).abs() > (p2.dy - p1.dy).abs()){
        n2_dx = p2.dx;
        n2_dy = p2.dy;
      }
      p.lineTo(n2_dx, n2_dy);
      canvas.drawPath(p, paint);

    }
  }
}