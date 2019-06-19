import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';

class CandlesticksContext extends InheritedWidget {
  final List<double> candlesX;//K线X坐标点
  final Function(ExtCandleData candleData) onCandleDataFinish;
  final ExtCandleData touchPointCandleData;//点击点的K线数据
  final Offset touchPoint;//点击点坐标
  final ExtCandleData lastCandleData;//最后一个K线数据
  bool touching;

  CandlesticksContext({
    Key key,
    @required this.candlesX,
    @required Widget child,
    @required this.onCandleDataFinish,
    @required this.touchPointCandleData,
    @required this.touchPoint,
    @required this.lastCandleData,
    @required this.touching,
  }) : super(key: key, child: child);

  static CandlesticksContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CandlesticksContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(CandlesticksContext oldWidget) {
    return candlesX != oldWidget.candlesX;
  }
}
