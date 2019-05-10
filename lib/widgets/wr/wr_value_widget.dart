import 'package:candlesticks/utils/string_util.dart';
import 'package:candlesticks/widgets/wr/wr_value_data.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class WrValuePainter extends CustomPainter {
  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle style;

  WrValueData wrValueData;
  Paint linePaint;

  WrValuePainter({
    this.uiCamera,
    this.paddingY,
    this.style,
    this.wrValueData,
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
    if (wrValueData.containsKey(style.wrStyle.shortPeriod)) {
      x = paintLabel(
          canvas,
          size,
          0,
          "WR(${style.wrStyle.shortPeriod}):" +
              StringUtil.formatAssetNum(
                  wrValueData.get(style.wrStyle.shortPeriod), 2),
          style.wrStyle.shortColor);
    }
    if (wrValueData.containsKey(style.wrStyle.middlePeriod)) {
      x += paintLabel(
          canvas,
          size,
          x,
          "WR(${style.wrStyle.middlePeriod}):" +
              StringUtil.formatAssetNum(
                  wrValueData.get(style.wrStyle.middlePeriod), 2),
          style.wrStyle.middleColor);
    }
    if (wrValueData.containsKey(style.wrStyle.longPeriod)) {
      x += paintLabel(
          canvas,
          size,
          x,
          "WR(${style.wrStyle.longPeriod}):" +
              StringUtil.formatAssetNum(
                  wrValueData.get(style.wrStyle.longPeriod), 2),
          style.wrStyle.longColor);
    }
  }

  @override
  bool shouldRepaint(WrValuePainter oldPainter) {
    if (wrValueData?.get(style.wrStyle.shortPeriod) !=
        oldPainter?.wrValueData?.get(style.wrStyle.shortPeriod)) {
      return true;
    }
    if (wrValueData?.get(style.wrStyle.middlePeriod) !=
        oldPainter?.wrValueData?.get(style.wrStyle.middlePeriod)) {
      return true;
    }
    if (wrValueData?.get(style.wrStyle.longPeriod) !=
        oldPainter?.wrValueData?.get(style.wrStyle.longPeriod)) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRebuildSemantics(WrValuePainter oldDelegate) {
    return false;
  }
}

class WrValueWidget extends StatelessWidget {
  WrValueWidget({
    Key key,
    this.wrValueData,
    this.style,
    this.paddingY,
  }) : super(key: key);

  final WrValueData wrValueData;
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
        painter: WrValuePainter(
          wrValueData: this.wrValueData,
          uiCamera: uiCamera,
          paddingY: paddingY,
          style: this.style,
        ),
        size: Size.infinite);
  }
}
