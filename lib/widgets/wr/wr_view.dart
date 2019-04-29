import 'package:candlesticks/widgets/boll/boll_context.dart';
import 'package:candlesticks/widgets/boll/boll_value_data.dart';
import 'package:candlesticks/widgets/boll/boll_value_widget.dart';
import 'package:candlesticks/widgets/rsi/rsi_context.dart';
import 'package:candlesticks/widgets/rsi/rsi_value_data.dart';
import 'package:candlesticks/widgets/rsi/rsi_value_widget.dart';
import 'package:candlesticks/widgets/rsi_period_config.dart';
import 'package:candlesticks/widgets/wr/wr_context.dart';
import 'package:candlesticks/widgets/wr/wr_value_data.dart';
import 'package:candlesticks/widgets/wr/wr_value_widget.dart';
import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'dart:math';

class WrView extends UIAnimatedView<UIOPath, UIOPoint> {
  List<double> _Hvalues;
  List<double> _Lvalues;
  Paint painter;
  Color color;
  int period = 20;

  WrContext wrContext;

  WrView({this.color, this.period}) : super(animationCount: 2) {
    this._Hvalues = List<double>();
    this._Lvalues = List<double>();

    painter = new Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
  }

  ///
  double getHigh(int period) {
    List<double> sub = _Hvalues.sublist(_Hvalues.length - period, _Hvalues.length);
    sub.sort();
    print('getHigh sub list:$sub                ${sub.last}');
    return sub.last;
  }

  ///
  double getLow(int period) {
    List<double> sub = _Lvalues.sublist(_Lvalues.length - period, _Lvalues.length);
    sub.sort();
    print('getLow sub list:$sub                ${sub.first}');
    return sub.first;
  }

  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    if (period == null || period == 0) {
      return null;
    }
    if (candleData == null) {
      return null;
    }
    if (candleData.index == _Lvalues.length - 1) {
      _Lvalues.last = candleData.low;
    } else {
      _Lvalues.add(candleData.low);
    }
    if (_Lvalues.length < period) {
      return null;
    }
    if (candleData.index == _Hvalues.length - 1) {
      _Hvalues.last = candleData.high;
    } else {
      _Hvalues.add(candleData.high);
    }
    if (_Hvalues.length < period) {
      return null;
    }
    //WR(N) = 100 * [ HIGH(N)-C ] / [ HIGH(N)-LOW(N) ]
    double c = candleData.close;
    double h = getHigh(period);
    double l = getLow(period);
    double y = 100 * (h - c)/(h - l);
    var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        y,
        index: candleData.index);
    wrContext.onWrChange(period,y);
    return point;
  }

  @override
  UIOPath getCandles() {
    return UIOPath([], painter: painter);
  }

  @override
  UIOPath getBeginAnimation(UIOPath lastAnimationUIObject, UIOPoint point) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(path.uiObjects.last.clone());
    return path;
  }

  @override
  UIOPath getEndAnimation(UIOPath lastAnimationUIObject, UIOPoint point) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(point);
    return path;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    wrContext = WrContext.of(context);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class WrWidgetState extends State<WrWidget> {
  AABBContext candlesticksContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  WrValueData wrValueData = WrValueData();

  onWrChange(int period, double wr) {
    wrValueData.put(period, wr);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = candlesticksContext?.uiCamera;
    return WrContext(
        onWrChange: onWrChange,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.wrStyle.duration,
                  state: () => WrView(
                    color: widget.style.wrStyle.shortColor,
                    period: widget.style.wrStyle.shortPeriod,
                  ),
                )),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.wrStyle.duration,
                  state: () => WrView(
                    color: widget.style.wrStyle.middleColor,
                    period: widget.style.wrStyle.middlePeriod,
                  ),
                )),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.wrStyle.duration,
                  state: () => WrView(
                    color: widget.style.wrStyle.longColor,
                    period: widget.style.wrStyle.longPeriod,
                  ),
                )),
            Positioned.fill(
                child: WrValueWidget(
                  wrValueData: wrValueData,
                  style: widget.style,
                )),
          ],
        ));
  }
}

class WrWidget extends StatefulWidget {
  WrWidget({
    Key key,
    this.dataStream,
    this.style,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;

  @override
  WrWidgetState createState() => WrWidgetState();
}
