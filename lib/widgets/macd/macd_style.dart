import 'package:flutter/material.dart';

class MacdStyle {
  Color difColor;
  Color deaColor;
  Color macdColor;

  double width;

  int S;
  int M;
  int L;

  MacdStyle({
    this.difColor,
    this.deaColor,
    this.macdColor,
    this.width,
    this.L = 26,
    this.S = 12,
    this.M = 9,
  });
}

MacdStyle defaultMacdStyle = MacdStyle(
  deaColor: Colors.yellowAccent,
  difColor: Colors.deepPurpleAccent,
  macdColor: Colors.white.withOpacity(0.85),
  width: 2,
);
