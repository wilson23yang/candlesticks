import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/boll/boll_value_data.dart';

class BollValuePainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle style;
  final Type type;

  BollValueData bollValueData;

  BollValuePainter({
    this.uiCamera,
    this.paddingY,
    this.style,
    this.bollValueData,
    this.type = Type.price,
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
    if(type == Type.price){
      int precision = StringUtil.getPrecision(bollValueData?.currentValue?.toStringAsFixed(style.fractionDigits));
      if(StringUtil.isEmpty(bollValueData?.currentValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      double x = paintLabel(canvas, size, 0, "Current:" + StringUtil.trimZero(bollValueData?.currentValue?.toStringAsFixed(style.fractionDigits), precision), style.maStyle.currentColor);
      if(StringUtil.isEmpty(bollValueData?.bollValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "BOLL:" + StringUtil.trimZero(bollValueData?.bollValue?.toStringAsFixed(style.fractionDigits), precision), style.maStyle.shortColor);
      if(StringUtil.isEmpty(bollValueData?.ubValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "UB:" + StringUtil.trimZero(bollValueData?.ubValue?.toStringAsFixed(style.fractionDigits), precision), style.maStyle.middleColor);
      if(StringUtil.isEmpty(bollValueData?.lbValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "LB:" + StringUtil.trimZero(bollValueData?.lbValue?.toStringAsFixed(style.fractionDigits), precision), style.maStyle.longColor);
    } else {
      if(StringUtil.isEmpty(bollValueData?.currentValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      double x = paintLabel(canvas, size, 0, "Current:" + StringUtil.abridge2KM(bollValueData?.currentValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.currentColor);
      if(StringUtil.isEmpty(bollValueData?.bollValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "BOLL:" + StringUtil.abridge2KM(bollValueData?.bollValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.shortColor);
      if(StringUtil.isEmpty(bollValueData?.ubValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "UB:" + StringUtil.abridge2KM(bollValueData?.ubValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.middleColor);
      if(StringUtil.isEmpty(bollValueData?.lbValue?.toStringAsFixed(style.fractionDigits))){
        return;
      }
      x += paintLabel(canvas, size, x, "LB:" + StringUtil.abridge2KM(bollValueData?.lbValue?.toStringAsFixed(style.fractionDigits)), style.maStyle.longColor);
    }

  }

  @override
  bool shouldRepaint(BollValuePainter oldPainter) {
    if(bollValueData?.currentValue != oldPainter?.bollValueData?.currentValue){
      return true;
    }
    if(bollValueData?.lbValue != oldPainter?.bollValueData?.lbValue){
      return true;
    }
    if(bollValueData?.ubValue != oldPainter?.bollValueData?.ubValue){
      return true;
    }
    if(bollValueData?.bollValue != oldPainter?.bollValueData?.bollValue){
      return true;
    }
    return false;
  }

  @override
  bool shouldRebuildSemantics(BollValuePainter oldDelegate) {
    return false;
  }
}

class BollValueWidget extends StatelessWidget {
  BollValueWidget({
    Key key,
    this.bollValueData,
    this.style,
    this.paddingY,
    this.type = Type.price,
  }) : super(key: key);

  final BollValueData bollValueData;
  final double paddingY;
  final CandlesticksStyle style;
  final Type type;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: BollValuePainter(
          bollValueData: this.bollValueData,
          uiCamera: uiCamera,
          paddingY: paddingY,
          style: this.style,
          type: this.type,
        ),
        size: Size.infinite
    );
  }
}

enum Type{
  price,vol,
}
