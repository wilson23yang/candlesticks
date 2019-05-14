import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class NetGridPainter extends CustomPainter {
  final CandlesticksStyle candlesticksStyle;
  final bool hideTopLine;
  final bool hideBottomLine;

  NetGridPainter({
    this.candlesticksStyle,
    this.hideTopLine,
    this.hideBottomLine,
  });

  void paintX(Canvas canvas, Size size, double x, Paint painter) {
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), painter);
  }

  void paintY(Canvas canvas, Size size, double y, Paint painter,
      {bool showText = true}) {
    canvas.drawLine(Offset(0, y), Offset(size.width, y), painter);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = candlesticksStyle.lineColor;
    double width = size.width / this.candlesticksStyle.nX;
    for (var i = 0; i <= this.candlesticksStyle.nX; i++) {
      paintX(canvas, size, width * i, painter);
    }
    if(!hideTopLine){
      paintY(canvas, size, 0, painter);
    }
    if(!hideBottomLine){
      paintY(canvas, size, size.height, painter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    return false;
  }
}

class NetGridWidget extends StatelessWidget {
  NetGridWidget({
    Key key,
    this.candlesticksStyle,
    this.hideTopLine = false,
    this.hideBottomLine = false,
  }) : super(key: key);

  final CandlesticksStyle candlesticksStyle;
  final bool hideTopLine;
  final bool hideBottomLine;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NetGridPainter(
        candlesticksStyle: this.candlesticksStyle,
        hideBottomLine: hideBottomLine,
        hideTopLine: hideTopLine
      ),
    );
  }
}
