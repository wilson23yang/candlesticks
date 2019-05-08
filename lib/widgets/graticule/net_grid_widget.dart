import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class NetGridPainter extends CustomPainter {
  final CandlesticksStyle candlesticksStyle;

  NetGridPainter({
    this.candlesticksStyle,
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
    paintY(canvas, size, 0, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class NetGridWidget extends StatelessWidget {
  NetGridWidget({
    Key key,
    this.candlesticksStyle,
  }) : super(key: key);

  final CandlesticksStyle candlesticksStyle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NetGridPainter(
        candlesticksStyle: this.candlesticksStyle,
      ),
    );
  }
}
