import 'package:candlesticks/utils/canvas_util.dart';
import 'package:candlesticks/utils/date_util.dart';
import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'dart:ui' as ui;

///
///K线长按查看选择点处的水平浮标线
///
class HorizontalLineFloatingPainter extends CustomPainter {
  final ExtCandleData extCandleData;
  final UICamera uiCamera;
  final Offset touchPoint;
  final CandlesticksStyle style;
  final double durationMs;
  Paint lastPointPainter;
  Paint lastLabelTextPainter;
  Paint lastBorderPainter;
  Paint lastBorderBgPainter;

  HorizontalLineFloatingPainter({
    this.uiCamera,
    this.extCandleData,
    this.touchPoint,
    this.style,
    this.durationMs,
  });

  TextPainter calLabel(Canvas canvas, Size size, String text) {
    TextPainter leftTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: style.hlfStyle.labelColor,
            fontSize: style.hlfStyle.textSize,
          ),
        ));
    leftTextPainter.layout();
    return leftTextPainter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (touchPoint == null) {
      return;
    }

    if (extCandleData == null || uiCamera == null) {
      return;
    }
    var touchWorldPoint = UIOPoint(
        extCandleData.timeMs + extCandleData.durationMs / 2,
        extCandleData.close);
    var touchScenePoint = uiCamera.viewPortToScreenPoint(
        size, uiCamera.worldToViewPortPoint(touchWorldPoint));
    var realPoint = Offset(touchScenePoint.dx, touchScenePoint.dy);

    if (lastLabelTextPainter == null) {
      lastLabelTextPainter = Paint();
      lastLabelTextPainter.color = style.hlfStyle.labelColor;
      lastLabelTextPainter.style = PaintingStyle.stroke;
    }
    if (lastBorderPainter == null) {
      lastBorderPainter = Paint();
      lastBorderPainter.color = style.hlfStyle.labelBorderColor;
      lastBorderPainter.strokeWidth = 1.2;
      lastBorderPainter.style = PaintingStyle.stroke;
    }
    if (lastBorderBgPainter == null) {
      lastBorderBgPainter = Paint();
      lastBorderBgPainter.color = style.hlfStyle.labelBgColor;
      lastBorderBgPainter.style = PaintingStyle.fill;
    }


    var labelText = calLabel(
        canvas,
        size,
        StringUtil.formatAssetNum(extCandleData.close.toString(),
            StringUtil.getPrecision(extCandleData.close)));

    double textWidth = labelText.width;
    double textHeight = labelText.height;
    double lGap = 4;
    double rGap = 4;
    double aGap = 8;
    double vGap = 3;

    if (realPoint.dx > size.width / 2.0) {
      //显示在右边
      //print('显示在右边');
      double dashLen = 100;

      Path path = Path();
      double rightPointXMax = realPoint.dx;
      double rightPointYMax = realPoint.dy;
      if (rightPointXMax > size.width) {
        rightPointXMax = size.width;
      }
      if (rightPointYMax > size.height) {
        rightPointYMax = size.height - textHeight / 2 - vGap;
      }
      if (rightPointYMax < 0) {
        rightPointYMax = textHeight / 2 + vGap;
      }
      Offset originPoint = Offset(2,
          rightPointYMax - textHeight / 2.0 - vGap);
      path.moveTo(originPoint.dx, originPoint.dy);
      path.lineTo(originPoint.dx + lGap + textWidth + rGap, originPoint.dy);
      path.lineTo(originPoint.dx + lGap + textWidth + rGap + aGap,
          originPoint.dy + textHeight / 2.0 + vGap);
      path.lineTo(originPoint.dx + lGap + textWidth + rGap,
          originPoint.dy + textHeight + 2 * vGap);
      path.lineTo(originPoint.dx, originPoint.dy + textHeight + 2 * vGap);
      path.close();
      canvas.drawPath(path, lastBorderPainter);
      canvas.drawPath(path, lastBorderBgPainter);

      labelText.paint(
          canvas, Offset(lGap + 2, rightPointYMax - textHeight / 2.0));

      canvas.drawLine(
          Offset(
              originPoint.dx + lGap + textWidth + rGap + aGap, rightPointYMax),
          Offset(size.width, rightPointYMax),
          lastBorderPainter);
    } else {
        //显示在左边
        //print('显示在左边');

        Path path = Path();
        double rightPointXMax = size.width - 2;
        double rightPointYMax = realPoint.dy;
        if (rightPointYMax > size.height) {
          rightPointYMax = size.height - textWidth / 2 - vGap;
        }
        if (rightPointYMax < 0) {
          rightPointYMax = textWidth / 2 + vGap;
        }
        Offset originPoint =
        Offset(rightPointXMax, rightPointYMax - textHeight / 2.0 - vGap);
        path.moveTo(originPoint.dx, originPoint.dy);
        path.lineTo(originPoint.dx - lGap - textWidth - rGap, originPoint.dy);
        path.lineTo(originPoint.dx - lGap - textWidth - rGap - aGap,
            originPoint.dy + textHeight / 2.0 + vGap);
        path.lineTo(originPoint.dx - lGap - textWidth - rGap,
            originPoint.dy + textHeight + 2 * vGap);
        path.lineTo(originPoint.dx, originPoint.dy + textHeight + 2 * vGap);
        path.close();
        canvas.drawPath(path, lastBorderPainter);
        canvas.drawPath(path, lastBorderBgPainter);

        labelText.paint(
            canvas,
            Offset(rightPointXMax - textWidth - rGap,
                rightPointYMax - textHeight / 2.0));

        Offset p1 = Offset(
            (originPoint.dx - lGap - textWidth - rGap - aGap), rightPointYMax);
        Offset p2 = Offset(0, rightPointYMax);
        canvas.drawLine(p1, p2, lastBorderPainter);
    }
  }

  @override
  bool shouldRepaint(HorizontalLineFloatingPainter oldPainter) {
    return this?.extCandleData?.durationMs !=
        oldPainter?.extCandleData?.durationMs;
  }

  @override
  bool shouldRebuildSemantics(HorizontalLineFloatingPainter oldDelegate) {
    return false;
  }
}

class HorizontalLineFloatingWidget extends StatelessWidget {
  HorizontalLineFloatingWidget({
    Key key,
    this.extCandleData,
    this.touchPoint,
    this.style,
    this.durationMs,
  }) : super(key: key);

  final CandlesticksStyle style;
  final ExtCandleData extCandleData;
  final Offset touchPoint;
  final double durationMs;

  @override
  Widget build(BuildContext context) {
    if (extCandleData == null) {
      return Container();
    }
    var uiCamera = AABBContext.of(context).uiCamera;
    return CustomPaint(
      painter: HorizontalLineFloatingPainter(
        style: style,
        uiCamera: uiCamera,
        touchPoint: touchPoint,
        extCandleData: extCandleData,
        durationMs: durationMs,
      ),
    );
  }
}
