import 'package:candlesticks/utils/string_util.dart';
import 'package:candlesticks/widgets/rsi/rsi_value_data.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class RsiValuePainter extends CustomPainter {
  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle style;

  RsiValueData rsiValueData;
  Paint linePaint;

  RsiValuePainter({
    this.uiCamera,
    this.paddingY,
    this.style,
    this.rsiValueData,
  }) {
    linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = style.lineColor;
  }

  double paintLabel(
      Canvas canvas, Size size, double x, String text, Color color) {
    TextPainter currentTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: 10.0,
          ),
        ));
    currentTextPainter.layout();
    currentTextPainter.paint(canvas, Offset(x, 2));
    return currentTextPainter.width + 8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), linePaint);
    double x = 0;
    if (rsiValueData.containsKey(style.rsiStyle.shortPeriod)) {
      x = paintLabel(
          canvas,
          size,
          0,
          "RSI(${style.rsiStyle.shortPeriod}):" +
              StringUtil.formatAssetNum(
                  rsiValueData.get(style.rsiStyle.shortPeriod), 2),
          style.rsiStyle.shortColor);
    }
    if (rsiValueData.containsKey(style.rsiStyle.middlePeriod)) {
      x += paintLabel(
          canvas,
          size,
          x,
          "RSI(${style.rsiStyle.middlePeriod}):" +
              StringUtil.formatAssetNum(
                  rsiValueData.get(style.rsiStyle.middlePeriod), 2),
          style.rsiStyle.middleColor);
    }
    if (rsiValueData.containsKey(style.rsiStyle.longPeriod)) {
      x += paintLabel(
          canvas,
          size,
          x,
          "RSI(${style.rsiStyle.longPeriod}):" +
              StringUtil.formatAssetNum(
                  rsiValueData.get(style.rsiStyle.longPeriod), 2),
          style.rsiStyle.longColor);
    }
  }

  @override
  bool shouldRepaint(RsiValuePainter oldPainter) {
    if (rsiValueData?.get(style.rsiStyle.shortPeriod) !=
        oldPainter?.rsiValueData?.get(style.rsiStyle.shortPeriod)) {
      return true;
    }
    if (rsiValueData?.get(style.rsiStyle.middlePeriod) !=
        oldPainter?.rsiValueData?.get(style.rsiStyle.middlePeriod)) {
      return true;
    }
    if (rsiValueData?.get(style.rsiStyle.longPeriod) !=
        oldPainter?.rsiValueData?.get(style.rsiStyle.longPeriod)) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRebuildSemantics(RsiValuePainter oldDelegate) {
    return false;
  }
}

class RsiValueWidget extends StatelessWidget {
  RsiValueWidget({
    Key key,
    this.rsiValueData,
    this.style,
    this.paddingY,
  }) : super(key: key);

  final RsiValueData rsiValueData;
  final double paddingY;
  final CandlesticksStyle style;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: RsiValuePainter(
          rsiValueData: this.rsiValueData,
          uiCamera: uiCamera,
          paddingY: paddingY,
          style: this.style,
        ),
        size: Size.infinite);
  }
}
