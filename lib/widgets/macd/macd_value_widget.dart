import 'package:candlesticks/utils/string_util.dart';
import 'package:candlesticks/widgets/kdj/kdj_value_data.dart';
import 'package:candlesticks/widgets/kdj/kdj_view.dart';
import 'package:candlesticks/widgets/macd/macd_value_data.dart';
import 'package:candlesticks/widgets/wr/wr_value_data.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class MACDValuePainter extends CustomPainter {
  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle style;

  MACDValueData macdValueData;
  Paint linePaint;

  MACDValuePainter({
    this.uiCamera,
    this.paddingY,
    this.style,
    this.macdValueData,
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
    if (macdValueData.containsKey(MACDValueKey.S)) {
      x = paintLabel(
          canvas,
          size,
          0,
          "MACD(${macdValueData.get( MACDValueKey.S,).toInt()},"
              "${macdValueData.get(MACDValueKey.L).toInt()},"
              "${macdValueData.get(MACDValueKey.M).toInt()})",
          style.macdStyle.macdColor);
    }
    if (macdValueData.containsKey(MACDValueKey.MACD)) {
      x += paintLabel(
          canvas,
          size,
          x,
          "MACD:" +
              StringUtil.formatAssetNum(
                  macdValueData.get(MACDValueKey.MACD), 6),
          style.macdStyle.macdColor);
    }
    if (macdValueData.containsKey(MACDValueKey.DIF)) {
      x += paintLabel(
          canvas,
          size,
          x,
          "DIF:" +
              StringUtil.formatAssetNum(macdValueData.get(MACDValueKey.DIF), 6),
          style.macdStyle.difColor);
    }
    if (macdValueData.containsKey(MACDValueKey.DEA)) {
      x += paintLabel(
          canvas,
          size,
          x,
          "DEA:" +
              StringUtil.formatAssetNum(macdValueData.get(MACDValueKey.DEA), 6),
          style.macdStyle.deaColor);
    }
  }

  @override
  bool shouldRepaint(MACDValuePainter oldPainter) {
    if (this?.macdValueData?.get(MACDValueKey.MACD) !=
        oldPainter?.macdValueData?.get(MACDValueKey.MACD)) {
      return true;
    }
    if (this?.macdValueData?.get(MACDValueKey.DIF) !=
        oldPainter?.macdValueData?.get(MACDValueKey.DIF)) {
      return true;
    }
    if (this?.macdValueData?.get(MACDValueKey.DEA) !=
        oldPainter?.macdValueData?.get(MACDValueKey.DEA)) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRebuildSemantics(MACDValuePainter oldDelegate) {
    return false;
  }
}

class MACDValueWidget extends StatelessWidget {
  MACDValueWidget({
    Key key,
    this.macdValueData,
    this.style,
    this.paddingY,
  }) : super(key: key);

  final MACDValueData macdValueData;
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
        painter: MACDValuePainter(
          macdValueData: this.macdValueData,
          uiCamera: uiCamera,
          paddingY: paddingY,
          style: this.style,
        ),
        size: Size.infinite);
  }
}
