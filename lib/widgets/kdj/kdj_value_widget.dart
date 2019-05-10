import 'package:candlesticks/utils/string_util.dart';
import 'package:candlesticks/widgets/kdj/kdj_value_data.dart';
import 'package:candlesticks/widgets/kdj/kdj_view.dart';
import 'package:candlesticks/widgets/wr/wr_value_data.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class KdjValuePainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle style;

  KdjValueData kdjValueData;
  Paint linePaint;

  KdjValuePainter({
    this.uiCamera,
    this.paddingY,
    this.style,
    this.kdjValueData,
  }) {
    linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = style.lineColor;
  }


  double paintLabel(Canvas canvas, Size size, double x, String text,
      Color color) {
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
        )
    );
    currentTextPainter.layout();
    currentTextPainter.paint(canvas, Offset(x, 2));
    return currentTextPainter.width + 8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), linePaint);
    double x = 0;
    if (kdjValueData.containsKey(KDJ.K)) {
      x = paintLabel(canvas, size, 0, "K:" +
          StringUtil.formatAssetNum(
              kdjValueData.get(KDJ.K), 6),
          style.wrStyle.shortColor);
    }
    if (kdjValueData.containsKey(KDJ.D)) {
      x += paintLabel(canvas, size, x, "D:" +
          StringUtil.formatAssetNum(
              kdjValueData.get(KDJ.D), 6),
          style.wrStyle.middleColor);
    }
    if (kdjValueData.containsKey(KDJ.J)) {
      x += paintLabel(canvas, size, x, "J:" +
          StringUtil.formatAssetNum(
              kdjValueData.get(KDJ.J), 6),
          style.wrStyle.longColor);
    }
  }

  @override
  bool shouldRepaint(KdjValuePainter oldPainter) {
    if(this?.kdjValueData?.get(KDJ.K) != oldPainter?.kdjValueData?.get(KDJ.K)){
      return true;
    }
    if(this?.kdjValueData?.get(KDJ.D) != oldPainter?.kdjValueData?.get(KDJ.D)){
      return true;
    }
    if(this?.kdjValueData?.get(KDJ.J) != oldPainter?.kdjValueData?.get(KDJ.J)){
      return true;
    }
    return false;
  }


  @override
  bool shouldRebuildSemantics(KdjValuePainter oldDelegate) {
    return false;
  }
}

class KdjValueWidget extends StatelessWidget {
  KdjValueWidget({
    Key key,
    this.kdjValueData,
    this.style,
    this.paddingY,
  }) : super(key: key);

  final KdjValueData kdjValueData;
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
        painter: KdjValuePainter(
          kdjValueData: this.kdjValueData,
          uiCamera: uiCamera,
          paddingY: paddingY,
          style: this.style,
        ),
        size: Size.infinite
    );
  }
}
