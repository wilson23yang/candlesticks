import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class MhVolumeValuePainter extends CustomPainter {
  final UICamera uiCamera;
  final CandlesticksStyle style;

  int precision;
  double vol;
  Paint linePaint;

  MhVolumeValuePainter({
    this.precision,
    this.uiCamera,
    this.style,
    this.vol,
  }) {
    linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = style.mhStyle.lineColor;
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
    paintLabel(
        canvas,
        size,
        0,
        "VOL:${StringUtil.formatAssetNum(vol, precision)}",
        style.mhStyle.volumeValueTextColor);
  }

  @override
  bool shouldRepaint(MhVolumeValuePainter oldPainter) {
    if (this?.vol != oldPainter?.vol) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRebuildSemantics(MhVolumeValuePainter oldDelegate) {
    return false;
  }
}

class MhVolumeValueWidget extends StatelessWidget {
  MhVolumeValueWidget({
    Key key,
    this.precision,
    this.vol,
    this.style,
  }) : super(key: key);

  final int precision;
  final double vol;
  final CandlesticksStyle style;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: MhVolumeValuePainter(
          precision:precision,
          vol: vol,
          uiCamera: uiCamera,
          style: this.style,
        ),
        size: Size.infinite);
  }
}
