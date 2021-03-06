import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_value_data.dart';

class MaValuePainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle style;
  final MaType maType;
  final int precision;

  MaValueData maValueData;

  MaValuePainter({
    this.uiCamera,
    this.paddingY,
    this.style,
    this.maValueData,
    this.maType = MaType.price,
    this.precision,
  });



  double paintLabel(Canvas canvas, Size size, double x, String text, Color color) {
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
    currentTextPainter.paint(canvas, Offset(x, 1));
    return currentTextPainter.width + 4;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if(maType == MaType.price){
      //int precision = StringUtil.getPrecision(maValueData?.currentValue?.toStringAsFixed(style.fractionDigits));
      if(StringUtil.isEmpty(maValueData?.currentValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      double x = paintLabel(canvas, size, 0, "Current:" + StringUtil.formatAssetNum(maValueData?.currentValue, precision), style.maStyle.currentColor);
      if(StringUtil.isEmpty(maValueData?.shortValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "MA${style.maStyle.shortCount}:" + StringUtil.formatAssetNum(maValueData?.shortValue, precision), style.maStyle.shortColor);
      if(StringUtil.isEmpty(maValueData?.middleValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "MA${style.maStyle.middleCount}:" + StringUtil.formatAssetNum(maValueData?.middleValue, precision), style.maStyle.middleColor);
      if(StringUtil.isEmpty(maValueData?.longValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "MA${style.maStyle.longCount}:" + StringUtil.formatAssetNum(maValueData?.longValue, precision), style.maStyle.longColor);
    } else {
      if(StringUtil.isEmpty(maValueData?.currentValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      double x = paintLabel(canvas, size, 0, "Current:" + StringUtil.abridge2KM(maValueData?.currentValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.currentColor);
      if(StringUtil.isEmpty(maValueData?.shortValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "MA${style.maStyle.shortCount}:" + StringUtil.abridge2KM(maValueData?.shortValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.shortColor);
      if(StringUtil.isEmpty(maValueData?.middleValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "MA${style.maStyle.middleCount}:" + StringUtil.abridge2KM(maValueData?.middleValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.middleColor);
      if(StringUtil.isEmpty(maValueData?.longValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "MA${style.maStyle.longCount}:" + StringUtil.abridge2KM(maValueData?.longValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.longColor);
    }

  }

  @override
  bool shouldRepaint(MaValuePainter oldPainter) {
    if(maValueData?.shortValue != oldPainter?.maValueData?.shortValue){
      return true;
    }
    if(maValueData?.middleValue != oldPainter?.maValueData?.middleValue){
      return true;
    }
    if(maValueData?.longValue != oldPainter?.maValueData?.longValue){
      return true;
    }
    return false;
  }

  @override
  bool shouldRebuildSemantics(MaValuePainter oldDelegate) {
    return false;
  }
}

class MaValueWidget extends StatelessWidget {
  MaValueWidget({
    Key key,
    this.maValueData,
    this.style,
    this.paddingY,
    this.maType = MaType.price,
    this.precision,
  }) : super(key: key);

  final MaValueData maValueData;
  final double paddingY;
  final CandlesticksStyle style;
  final MaType maType;
  final int precision;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: MaValuePainter(
          maValueData: this.maValueData,
          uiCamera: uiCamera,
          paddingY: paddingY,
          style: this.style,
          maType: this.maType,
          precision: precision,
        ),
        size: Size.infinite
    );
  }
}

enum MaType{
  price,vol,
}
