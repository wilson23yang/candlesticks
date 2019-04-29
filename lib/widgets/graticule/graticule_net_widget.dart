import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class GraticuleNetPainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle candlesticksStyle;

  GraticuleNetPainter({
    this.uiCamera,
    this.paddingY,
    this.candlesticksStyle,
  });

  void paintX(Canvas canvas, Size size, double x, Paint painter) {
    var point = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(size, Offset(x, 0)));
    var worldX = point.x;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), painter);
  }

  void paintY(Canvas canvas, Size size, double y, Paint painter,{bool showText = true}) {
    var point = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(size, Offset(0, y)));
    var worldY = point.y;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), painter);

    if(showText){
      var priceStr = worldY.toStringAsFixed(this.candlesticksStyle.fractionDigits);
      TextPainter textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          maxLines: 1,
          textAlign: TextAlign.end,
          text: TextSpan(
            text: priceStr,
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 10.0,
            ),
          )
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - textPainter.width, y));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = candlesticksStyle.lineColor;
    double width = size.width / this.candlesticksStyle.nX;
    for(var i = 0; i <= this.candlesticksStyle.nX; i++) {
      paintX(canvas, size, width * i, painter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class GraticuleNetWidget extends StatelessWidget {
  GraticuleNetWidget({
    Key key,
    this.candlesticksStyle,
    this.paddingY,
  }) : super(key: key);

  final double paddingY;
  final CandlesticksStyle candlesticksStyle;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: GraticuleNetPainter(
          uiCamera: uiCamera,
          paddingY: paddingY,
          candlesticksStyle: this.candlesticksStyle,
        ),
        size: Size.infinite
    );
  }
}
