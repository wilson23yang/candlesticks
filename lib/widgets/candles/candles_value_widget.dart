import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class CandlesValuePainter extends CustomPainter {

  final UICamera uiCamera;
  final UIOPoint point;
  final CandlesticksStyle style;

  CandlesValuePainter({
    this.uiCamera,
    this.point,
    this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dx = 20;
    Offset p = uiCamera.viewPortToScreenPoint(size, uiCamera.worldToViewPortPoint(point));

    double dir = 1;
    if(p.dx > size.width / 2) {
      dir = -1;
    }
    Offset pText = p + Offset(dx, 0) * dir;
//    String price = point.y.toStringAsFixed(style.fractionDigits);
    String price = StringUtil.formatAssetNum(point.y.toString(),
        StringUtil.getPrecision(point.y));


    TextPainter currentTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: "$price",
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
          ),
        )
    );
    currentTextPainter.layout();
//    p += Offset(0, -currentTextPainter.height / 2);
    var pLeftTop = pText + Offset(0, -currentTextPainter.height / 2) - Offset(dir<0?currentTextPainter.width:0, 0);
    if(pLeftTop.dy + currentTextPainter.height > size.height) {
      return;
    }
    currentTextPainter.paint(canvas, pLeftTop);

    var linePainter = Paint()..color=Colors.white;
    canvas.drawLine(p, pText, linePainter);

    Paint maxCircle = new Paint();
//      maxCircle..color = kStyle.priceMinMaxFontColor.withOpacity(0.3);
    maxCircle..shader = ui.Gradient.radial(pText, 3, [
      Colors.white.withOpacity(0.8),
      Colors.white.withOpacity(0.1),
    ], [0.0, 1.0], TileMode.clamp);
    canvas.drawCircle(p, 3, maxCircle);
  }

  @override
  bool shouldRepaint(CandlesValuePainter oldPainter) {
    return this.point != oldPainter.point || this.uiCamera != oldPainter.uiCamera;
  }

  @override
  bool shouldRebuildSemantics(CandlesValuePainter oldDelegate) {
    return false;
  }
}

class CandlesValueWidget extends StatelessWidget {
  CandlesValueWidget({
    Key key,
    this.point,
    this.style
  }) : super(key: key);

  final CandlesticksStyle style;
  final UIOPoint point;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: CandlesValuePainter(
          style: style,
          uiCamera: uiCamera,
          point: point,
        ),
        size: Size.infinite
    );
  }
}
