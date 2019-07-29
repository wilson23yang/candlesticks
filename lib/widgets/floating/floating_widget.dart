import 'package:candlesticks/utils/date_util.dart';
import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'dart:ui' as ui;

class TopFloatingPainter extends CustomPainter {

  final ExtCandleData extCandleData;
  final UICamera uiCamera;
  final Offset touchPoint;
  final CandlesticksStyle style;
  final double durationMs;

  TopFloatingPainter({
    this.uiCamera,
    this.extCandleData,
    this.touchPoint,
    this.style,
    this.durationMs,
  });


  TextPainter calLabel(Canvas canvas, Size size, bool alignLeft, String text) {
    TextPainter leftTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: style.floatingStyle.frontColor,
            fontSize: style.floatingStyle.frontSize,
          ),
        )
    );
    leftTextPainter.layout();
    return leftTextPainter;
  }

  Offset paintLabel(Canvas canvas, Size size, String key, String value,
      Offset origin, double width, {bool real = true}) {
    var leftLabel = calLabel(canvas, size, true, key);
    leftLabel.paint(canvas, origin);
    var rightLabel = calLabel(canvas, size, true, value);
    if (real) {
      rightLabel.paint(
          canvas, Offset(origin.dx + width - rightLabel.width, origin.dy));
    }
    return Offset(origin.dx, origin.dy + leftLabel.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (extCandleData == null) {
      return;
    }
    var point = uiCamera
        .viewPortToScreenPoint(size, uiCamera.worldToViewPortPoint(
        UIOPoint(extCandleData.timeMs.toDouble(), extCandleData.close)));

    var sceneX = point.dx;
    var sceneY = point.dy;
    //print('extCandleData......$sceneX      $sceneY');
    double width = 110;
    if (width < style.floatingStyle.minWidth) {
      width = style.floatingStyle.minWidth;
    }
    var leftTop = Offset(0+10.0, 20);
    if (sceneX < size.width / 2) {
      leftTop = Offset(size.width - width - 10.0, 20);
    } else {
      leftTop = Offset(0 + 10.0, 20);
    }

    var time = new DateTime.fromMillisecondsSinceEpoch(extCandleData.timeMs);
    var timeStamp = time.toLocal().toString();
    if(durationMs >= 1000 * 60 * 60 * 24){//天
      timeStamp = DateUtil.toYMD(extCandleData.timeMs);
    } else {
      timeStamp = DateUtil.toMMddHHmm(extCandleData.timeMs);
    }

    int precision = StringUtil.getPrecision(extCandleData.open,defaultPrecision:4);

    var p = paintLabel(canvas, size, "时间", timeStamp, Offset(leftTop.dx, leftTop.dy), width);
    p = paintLabel(
        canvas, size, "开", StringUtil.trimZero(extCandleData.open.toStringAsFixed(style.fractionDigits), precision), p, width,
        real: false);
    p = paintLabel(
        canvas, size, "高", StringUtil.trimZero(extCandleData.high.toStringAsFixed(style.fractionDigits), precision), p, width,
        real: false);
    p = paintLabel(
        canvas, size, "收", StringUtil.trimZero(extCandleData.close.toStringAsFixed(style.fractionDigits), precision), p, width,
        real: false);
    p = paintLabel(
        canvas, size, "低", StringUtil.trimZero(extCandleData.low.toStringAsFixed(style.fractionDigits), precision), p, width,
        real: false);
    p = paintLabel(
        canvas, size, "量", StringUtil.trimZero(extCandleData.volume.toStringAsFixed(style.fractionDigits), precision), p, width,
        real: false);
    var rightBottom = Offset(p.dx + width, p.dy);
    var linePainter = Paint();
    linePainter.color = Colors.black.withOpacity(0.5);
    linePainter.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromPoints(Offset(leftTop.dx - 5, leftTop.dy - 3), Offset(rightBottom.dx + 5, rightBottom.dy + 3)), linePainter);

    p = paintLabel(canvas, size, "时间", timeStamp, leftTop, width);
    p = paintLabel(
        canvas, size, "开", StringUtil.trimZero(extCandleData.open.toStringAsFixed(style.fractionDigits), precision), p, width);
    p = paintLabel(
        canvas, size, "高", StringUtil.trimZero(extCandleData.high.toStringAsFixed(style.fractionDigits), precision), p, width);
    p = paintLabel(
        canvas, size, "收", StringUtil.trimZero(extCandleData.close.toStringAsFixed(style.fractionDigits), precision), p, width);
    p = paintLabel(
        canvas, size, "低", StringUtil.trimZero(extCandleData.low.toStringAsFixed(style.fractionDigits), precision), p, width);
    p = paintLabel(
        canvas, size, "量", StringUtil.trimZero(extCandleData.volume.toStringAsFixed(style.fractionDigits), precision), p, width);

    var backgroundPainter = Paint();
    backgroundPainter.color = style.floatingStyle.backGroundColor;
    backgroundPainter.style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromPoints(Offset(leftTop.dx - 5, leftTop.dy - 3), Offset(rightBottom.dx + 5, rightBottom.dy + 3)), backgroundPainter);

    var borderPainter = Paint();
    borderPainter.color = style.floatingStyle.borderColor;
    borderPainter.style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromPoints(Offset(leftTop.dx - 5, leftTop.dy - 3), Offset(rightBottom.dx + 5, rightBottom.dy + 3)), borderPainter);

    var crossPainter = Paint();
    crossPainter.color = style.floatingStyle.crossColor;
    crossPainter.strokeWidth = 0.6;
    crossPainter.style = PaintingStyle.stroke;
    var touchWorldPoint = UIOPoint(extCandleData.timeMs + extCandleData.durationMs / 2, extCandleData.close);
    var touchScenePoint = uiCamera.viewPortToScreenPoint(size, uiCamera.worldToViewPortPoint(touchWorldPoint));
    var realTouchPoint = Offset(touchScenePoint.dx, touchScenePoint.dy);
//    canvas.drawLine(
//        Offset(touchScenePoint.dx, 0), Offset(touchScenePoint.dx, size.height),
//        crossPainter);
//    canvas.drawLine(Offset(0, realTouchPoint.dy), Offset(size.width, realTouchPoint.dy),
//        crossPainter);
    Paint maxCircle = new Paint();
    maxCircle
      ..shader = ui.Gradient.radial(realTouchPoint, 100, [
        Colors.white.withOpacity(0.26),
        Colors.white.withOpacity(0.1),
      ], [0.0, 1.0], TileMode.clamp);
    canvas.drawCircle(realTouchPoint, 12, maxCircle);
    canvas.drawCircle(realTouchPoint, 2.6, new Paint()..color=Colors.white);
  }

  @override
  bool shouldRepaint(TopFloatingPainter oldPainter) {
    return false;
  }

  @override
  bool shouldRebuildSemantics(TopFloatingPainter oldDelegate) {
    return false;
  }
}


class FloatingWidget extends StatelessWidget {

  FloatingWidget({
    Key key,
    this.extCandleData,
    this.touchPoint,
    this.style,
    this.durationMs,
  }) :super(key: key);

  final CandlesticksStyle style;
  final ExtCandleData extCandleData;
  final Offset touchPoint;
  final double durationMs;

  Widget getText(String text, String data, TextStyle textStyle,
      [TextStyle textStyleColor,]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Text(text,
            style: textStyleColor is TextStyle ? textStyleColor : textStyle,
            textAlign: TextAlign.left,),
        ),
        new Expanded(
          flex: 8,
          child: new Text(
            data, style: textStyle, textAlign: TextAlign.right,),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (extCandleData == null) {
      return Container();
    }
    var uiCamera = AABBContext
        .of(context)
        .uiCamera;
    return CustomPaint(
      painter: TopFloatingPainter(
        style: style,
        uiCamera: uiCamera,
        touchPoint: touchPoint,
        extCandleData: extCandleData,
        durationMs: durationMs,
      ),
    );
  }
}
