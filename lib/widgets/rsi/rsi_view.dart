import 'dart:async';

import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/rsi/rsi_context.dart';
import 'package:candlesticks/widgets/rsi/rsi_value_data.dart';
import 'package:candlesticks/widgets/rsi/rsi_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class RsiView extends UIAnimatedView<UIOPath, UIOPoint> {
  List<double> _values;
  Paint painter;
  Color color;
  int period = 20;

  Map<int, double> rsi;

  RsiContext rsiContext;

  RsiView({
    @required this.color,
    @required this.period,
    @required this.rsi,
  }) : super(animationCount: 2) {
    this._values = List<double>();

    painter = new Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
  }

  ///
  double gainAverage(int period) {
    double sum = _values
        .sublist(_values.length - period, _values.length)
        .reduce((double a, double b) {
      double _sum = 0;
      if (a >= 0) {
        _sum = a;
      }
      return _sum + (b >= 0 ? b : 0);
    });
    return sum / period;
  }

  ///
  double declineAverage(int period) {
    double sum = _values
        .sublist(_values.length - period, _values.length)
        .reduce((double a, double b) {
      double _sum = 0;
      if (a < 0) {
        _sum = a;
      }
      return _sum + (b < 0 ? b : 0);
    });
    return sum / period;
  }

  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    if (period == null || period == 0) {
      return null;
    }
    if (candleData == null) {
      return null;
    }
    if (candleData.index == _values.length - 1) {
      _values.last = candleData.close - candleData.open;
    } else {
      _values.add(candleData.close - candleData.open);
    }
    if (_values.length < period) {
      return null;
    }

    double gain = gainAverage(period);
    double decline = declineAverage(period);

    if (gain.abs() + decline.abs() == 0) {
      return null;
    }

    double y = gain * 100 / (gain.abs() + decline.abs());
    if (y == null) {
      return null;
    }
    var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        y,
        index: candleData.index);
    rsiContext.onRsiChange(period, y);
    rsi[candleData.index] = y;
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
    rsiContext = RsiContext.of(context);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class RsiWidgetState extends State<RsiWidget> with SingleTickerProviderStateMixin{
  AABBContext aabbContext;
  CandlesticksContext candlesticksContext;
  Map<int, double> rsiShort = <int, double>{};
  Map<int, double> rsiMiddle = <int, double>{};
  Map<int, double> rsiLong = <int, double>{};
  var lastRsiShort;
  var lastRsiMiddle;
  var lastRsiLong;

  AnimationController _controller;
  Animation<RsiValueData> animationObject;
  Timer _animationStartTimer;
  bool startAnimationShow = false;
  bool isShowClickData = false;//是否正在显示指定时间点的指标

  RsiValueData rsiValueData = RsiValueData();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 500));
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aabbContext = AABBContext.of(context);
    candlesticksContext = CandlesticksContext.of(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationStartTimer?.cancel();
    super.dispose();
  }


  ///
  void startAnimation(){
    if(_animationStartTimer == null){
      _animationStartTimer = Timer(const Duration(seconds: 2), (){
        startAnimationShow = true;
      });
    }
  }

  bool updateShort = false;
  bool updateMiddle = false;
  bool updateLong = false;
  RsiValueData begin;

  onRsiChange(int period, double rsi) {
    startAnimation();

    if(!updateShort && !updateMiddle && !updateLong){
      begin = rsiValueData.clone();
    }
    if(widget.style.rsiStyle.shortPeriod == period){
      lastRsiShort = rsi;
      RsiPeriod.short = widget.style.rsiStyle.shortPeriod;
      if(startAnimationShow){
        updateShort = true;
      }
    }
    if(widget.style.rsiStyle.middlePeriod == period){
      lastRsiMiddle = rsi;
      RsiPeriod.middle = widget.style.rsiStyle.middlePeriod;
      if(startAnimationShow){
        updateMiddle = true;
      }
    }
    if(widget.style.rsiStyle.longPeriod == period){
      lastRsiLong = rsi;
      RsiPeriod.long = widget.style.rsiStyle.longPeriod;
      if(startAnimationShow){
        updateLong = true;
      }
    }
    if (candlesticksContext?.touchPointCandleData != null) {
      animationObject = null;
      _controller?.stop();
      return;
    }
    rsiValueData.put(period, rsi);
    if(startAnimationShow && updateShort && updateMiddle && updateLong){
      animationObject = null;
      _controller.reset();
      animationObject = Tween(begin: begin,end: rsiValueData).animate(_controller);
      animationObject.addListener((){
        if(mounted)
          setState(() {});
      });
      _controller.forward();
      updateShort = false;
      updateMiddle = false;
      updateLong = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    setThisPositionRsi();
    var uiCamera = aabbContext?.uiCamera;
    return RsiContext(
      onRsiChange: onRsiChange,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.rsiStyle.duration,
              state: () => RsiView(
                    color: widget.style.rsiStyle.shortColor,
                    period: widget.style.rsiStyle.shortPeriod,
                    rsi: rsiShort,
                  ),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.rsiStyle.duration,
              state: () => RsiView(
                    color: widget.style.rsiStyle.middleColor,
                    period: widget.style.rsiStyle.middlePeriod,
                    rsi: rsiMiddle,
                  ),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.rsiStyle.duration,
              state: () => RsiView(
                  color: widget.style.rsiStyle.longColor,
                  period: widget.style.rsiStyle.longPeriod,
                  rsi: rsiLong),
            ),
          ),
          Positioned.fill(
            child: RsiValueWidget(
              rsiValueData: animationObject?.value ?? rsiValueData,
              style: widget.style,
            ),
          ),
        ],
      ),
    );
  }

  ///设置指定时间点的RSI
  void setThisPositionRsi(){
    if (candlesticksContext != null &&
        candlesticksContext.touchPointCandleData != null) {
      isShowClickData = true;
      if(rsiShort.containsKey(candlesticksContext.touchPointCandleData.index)){
        rsiValueData.put(widget.style.rsiStyle.shortPeriod, rsiShort[candlesticksContext.touchPointCandleData.index]);
      } else {
        rsiValueData.remove(widget.style.rsiStyle.shortPeriod);
      }
      if(rsiMiddle.containsKey(candlesticksContext.touchPointCandleData.index)){
        rsiValueData.put(widget.style.rsiStyle.middlePeriod, rsiMiddle[candlesticksContext.touchPointCandleData.index]);
      } else {
        rsiValueData.remove(widget.style.rsiStyle.middlePeriod);
      }
      if(rsiLong.containsKey(candlesticksContext.touchPointCandleData.index)){
        rsiValueData.put(widget.style.rsiStyle.longPeriod, rsiLong[candlesticksContext.touchPointCandleData.index]);
      } else {
        rsiValueData.remove(widget.style.rsiStyle.longPeriod);
      }
      if(mounted){
        setState(() {});
      }
    } else if (candlesticksContext.touchPointCandleData == null && isShowClickData) {
      isShowClickData = false;
      if(lastRsiShort != null){
        rsiValueData.put(widget.style.rsiStyle.shortPeriod, lastRsiShort);
      } else {
        rsiValueData.remove(widget.style.rsiStyle.shortPeriod);
      }
      if(lastRsiMiddle != null){
        rsiValueData.put(widget.style.rsiStyle.middlePeriod, lastRsiMiddle);
      } else {
        rsiValueData.remove(widget.style.rsiStyle.middlePeriod);
      }
      if(lastRsiLong != null){
        rsiValueData.put(widget.style.rsiStyle.longPeriod, lastRsiLong);
      } else {
        rsiValueData.remove(widget.style.rsiStyle.longPeriod);
      }
      if(mounted){
        setState(() {
          animationObject = null;
        });
      }
    }
  }
}

class RsiWidget extends StatefulWidget {
  RsiWidget({
    Key key,
    this.dataStream,
    this.style,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;

  @override
  RsiWidgetState createState() => RsiWidgetState();
}
