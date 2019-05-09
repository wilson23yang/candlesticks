import 'package:candlesticks/utils/date_util.dart';
import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'dart:ui' as ui;

class VerticalLineFloatingPainter extends CustomPainter {
  final ExtCandleData extCandleData;
  final UICamera uiCamera;
  final Offset touchPoint;
  final CandlesticksStyle style;
  final double durationMs;

  VerticalLineFloatingPainter({
    this.uiCamera,
    this.extCandleData,
    this.touchPoint,
    this.style,
    this.durationMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (extCandleData == null) {
      return;
    }

    var left = UIOPoint(
        extCandleData.timeMs.toDouble(),
        extCandleData.close);
    var leftScreenPoint = uiCamera.viewPortToScreenPoint(
        size, uiCamera.worldToViewPortPoint(left));

    var middle = UIOPoint(
        extCandleData.timeMs.toDouble() + extCandleData.durationMs / 2,
        extCandleData.close);
    var middleScreenPoint = uiCamera.viewPortToScreenPoint(
        size, uiCamera.worldToViewPortPoint(middle));

    var right = UIOPoint(
        extCandleData.timeMs.toDouble() + extCandleData.durationMs,
        extCandleData.close);
    var rightScreenPoint = uiCamera.viewPortToScreenPoint(
        size, uiCamera.worldToViewPortPoint(right));

    var crossPainter = Paint();

    crossPainter
      ..shader = ui.Gradient.radial(
          Offset(middleScreenPoint.dx, size.height / 2),
          size.height / 2,
          [
            style.floatingStyle.crossColor.withOpacity(0.3),
            style.floatingStyle.crossColor.withOpacity(0.0),
          ],
          [0.0, 0.979],
          TileMode.clamp);

    canvas.drawRect(
      Rect.fromLTRB(
        leftScreenPoint.dx + style.candlesStyle.paddingX,
        0,
        rightScreenPoint.dx - style.candlesStyle.paddingX,
        size.height,
      ),
      crossPainter,
    );
  }

  @override
  bool shouldRepaint(VerticalLineFloatingPainter oldPainter) {
    return false;
  }
}

class VerticalLineFloatingWidget extends StatelessWidget {
  VerticalLineFloatingWidget({
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
      painter: VerticalLineFloatingPainter(
        style: style,
        uiCamera: uiCamera,
        touchPoint: touchPoint,
        extCandleData: extCandleData,
        durationMs: durationMs,
      ),
    );
  }
}
