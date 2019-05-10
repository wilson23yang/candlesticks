import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class TimeGraticulePainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle candlesticksStyle;
  final Offset touchPoint;

  TimeGraticulePainter({
    this.uiCamera,
    this.paddingY,
    this.candlesticksStyle,
    this.touchPoint
  });

  void paintX(Canvas canvas, Size size, double x, Paint painter) {
    var point = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(size, Offset(x, 0)));
    var time = new DateTime.fromMillisecondsSinceEpoch(point.x.toInt()).toLocal();
    String timeStr ="${time.month.toString().padLeft(2,'0')}-${time.day.toString().padLeft(2,'0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: timeStr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 8.0,
          ),
        )
    );

    textPainter.layout();
//    if((x - textPainter.width / 2 >= 0) && (x + textPainter.width / 2 <= size.width)) {
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - textPainter.height));
//    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    //五条线。
    // 绘制代码
    var painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = candlesticksStyle.lineColor;
    double width = size.width / this.candlesticksStyle.nX;
    for(var i = 0; i <= this.candlesticksStyle.nX; i++) {
      paintX(canvas, size, width * i, painter);
    }
  }

  @override
  bool shouldRepaint(TimeGraticulePainter oldDelegate) {
    return this?.touchPoint?.dx != oldDelegate?.touchPoint?.dx;
  }

  @override
  bool shouldRebuildSemantics(TimeGraticulePainter oldDelegate) {
    return false;
  }
}

class TimeGraticuleWidget extends StatelessWidget {
  TimeGraticuleWidget({
    Key key,
    this.candlesticksStyle,
    this.paddingY,
    this.touchPoint,
  }) : super(key: key);

  final double paddingY;
  final CandlesticksStyle candlesticksStyle;
  final Offset touchPoint;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: TimeGraticulePainter(
          uiCamera: uiCamera,
          paddingY: paddingY,
          candlesticksStyle: this.candlesticksStyle,
          touchPoint:touchPoint,
        ),
        size: Size.infinite
    );
  }
}
