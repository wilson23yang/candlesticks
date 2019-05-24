import 'dart:async';

import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/macd/macd_context.dart';
import 'package:candlesticks/widgets/macd/macd_value_data.dart';
import 'package:candlesticks/widgets/macd/macd_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_candles.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class MacdCandlesView extends UIAnimatedView<UIOCandles, UIOCandle> {
  final CandlesticksStyle style;
  Paint positivePainter;
  Paint negativePainter;

  Map<int, double> shortEMAMap;
  Map<int, double> longEMAMap;
  Map<int, double> difMap;
  Map<int, double> deaMap;
  Map<int, double> macdMap;

  MACDContext macdContext;

  int middleDuration;
  double newDuration;


  MacdCandlesView({
    this.positivePainter,
    this.negativePainter,
    this.style,
    this.shortEMAMap,
    this.longEMAMap,
    this.difMap,
    this.deaMap,
    this.macdMap,
  }) : super(animationCount: 2);

  @override
  UIOCandle getCandle(ExtCandleData candleData) {
    double ema12 = ema(candleData, shortEMAMap, style.macdStyle.S);
    if (ema12 == null) {
      return null;
    }
    double ema26 = ema(candleData, longEMAMap, style.macdStyle.L);
    if (ema26 == null) {
      return null;
    }
    double dif = ema12 - ema26;
    difMap[candleData.index] = dif;
    double deaValue = dea(difMap, deaMap, candleData.index);
    if (candleData.index < style.macdStyle.L) {
      return null;
    }
    macdMap[candleData.index] = (dif - deaValue) * 2;
    //用（DIF-DEA）×2即为MACD柱状图
    if(middleDuration == null || newDuration == null){
      middleDuration = candleData.durationMs~/2 - candleData.durationMs~/10;
      newDuration = candleData.durationMs/5;
    }
    CandleData candleDataClone = CandleData(
        timeMs: candleData.timeMs + middleDuration,
        open: 0,
        close: (dif - deaValue) * 2,
        high: (dif - deaValue) * 2,
        low: 0,
        volume: (dif - deaValue) * 2);

    ExtCandleData extCandleData = ExtCandleData(candleDataClone,
        index: candleData.index,
        durationMs: newDuration,
        first: candleData.first,
        getValue: candleData.getValue);
    var candleUIObject = UIOCandle.fromData(
        extCandleData,
        0,
        extCandleData.open <= extCandleData.close
            ? positivePainter
            : negativePainter,
        index: extCandleData.index);
    macdContext.onMacdChange(candleData.index,deaValue, dif, (dif - deaValue) * 2);
    return candleUIObject;
  }

  @override
  UIOCandles getCandles() {
    return UIOCandles([]);
  }

  @override
  UIOCandles getBeginAnimation(
      UIOCandles lastAnimationUIObject, UIOCandle candleUIObject) {
    var path = lastAnimationUIObject.clone();
    var currentCandle = UIOCandle(
        UIOPoint(candleUIObject.origin.x, candleUIObject.origin.y),
        UIOPoint(candleUIObject.r.x, 0),
        0,
        0,
        0,
        painter: candleUIObject.painter,
        index: candleUIObject.index);
    path.uiObjects.add(currentCandle);

    return path;
  }

  @override
  UIOCandles getEndAnimation(
      UIOCandles lastAnimationUIObject, UIOCandle candleUIObject) {
    var path = lastAnimationUIObject.clone();
    path.uiObjects.add(candleUIObject);
    return path;
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    macdContext = MACDContext.of(context);
  }

  ///
  double ema(ExtCandleData candleData, Map<int, double> map, int n) {
    double preEMA = 0;
    if (candleData.index == 0) {
      double ema1 = candleData.close;
      map[0] = ema1;
      return map[0];
    }
    if (candleData.index > 0) {
      preEMA = map[candleData.index - 1];
      map[candleData.index] =
          preEMA * (n - 1) / (n + 1) + candleData.close * 2 / (n + 1);
      return map[candleData.index];
    }
    return null;
  }

  ///
  double dea(Map<int, double> difMap, Map<int, double> deaMap, int index) {
    if (index == 0) {
      deaMap[0] = difMap[0];
      return deaMap[0];
    }
    //今日DEA（MACD）=前一日DEA×8/10+今日DIF×2/10。
    deaMap[index] =
        deaMap[index - 1] * (style.macdStyle.M - 1) / (style.macdStyle.M + 1) +
            difMap[index] * 2 / (style.macdStyle.M + 1);
    return deaMap[index];
  }
}

class DEAView extends UIAnimatedView<UIOPath, UIOPoint> {
  final CandlesticksStyle style;
  Paint painter;

  Map<int, double> shortEMAMap;
  Map<int, double> longEMAMap;
  Map<int, double> difMap;
  Map<int, double> deaMap;
  Map<int, double> macdMap;
  Color color;

  DEAView(
      {this.style,
      this.painter,
      this.shortEMAMap,
      this.longEMAMap,
      this.difMap,
      this.deaMap,
      this.macdMap,
      this.color})
      : super(animationCount: 2) {
    painter = new Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
  }

  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    double ema12 = ema(candleData, shortEMAMap, style.macdStyle.S);
    if (ema12 == null) {
      return null;
    }
    double ema26 = ema(candleData, longEMAMap, style.macdStyle.L);
    if (ema26 == null) {
      return null;
    }
    double dif = ema12 - ema26;
    difMap[candleData.index] = dif;
    double deaValue = dea(difMap, deaMap, candleData.index);
    if (candleData.index < style.macdStyle.L) {
      return null;
    }
    var point = UIOPoint(
      candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
      deaValue,
      index: candleData.index,
    );
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
  @mustCallSuper
  void initState() {
    super.initState();
  }

  ///
  double ema(ExtCandleData candleData, Map<int, double> map, int n) {
    double preEMA = 0;
    if (candleData.index == 0) {
      double ema1 = candleData.close;
      map[0] = ema1;
      return map[0];
    }
    if (candleData.index > 0) {
      preEMA = map[candleData.index - 1];
      map[candleData.index] =
          preEMA * (n - 1) / (n + 1) + candleData.close * 2 / (n + 1);
      return map[candleData.index];
    }
    return null;
  }

  ///
  double dea(Map<int, double> difMap, Map<int, double> deaMap, int index) {
    if (index == 0) {
      deaMap[0] = difMap[0];
      return deaMap[0];
    }
    //今日DEA（MACD）=前一日DEA×8/10+今日DIF×2/10。
    deaMap[index] =
        deaMap[index - 1] * (style.macdStyle.M - 1) / (style.macdStyle.M + 1) +
            difMap[index] * 2 / (style.macdStyle.M + 1);
    return deaMap[index];
  }
}

class DIFView extends UIAnimatedView<UIOPath, UIOPoint> {
  final CandlesticksStyle style;
  Paint painter;

  Map<int, double> shortEMAMap;
  Map<int, double> longEMAMap;
  Map<int, double> difMap;
  Map<int, double> deaMap;
  Map<int, double> macdMap;
  Color color;

  DIFView(
      {this.style,
      this.painter,
      this.shortEMAMap,
      this.longEMAMap,
      this.difMap,
      this.deaMap,
      this.macdMap,
      this.color})
      : super(animationCount: 2) {
    painter = new Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
  }

  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    double ema12 = ema(candleData, shortEMAMap, style.macdStyle.S);
    if (ema12 == null) {
      return null;
    }
    double ema26 = ema(candleData, longEMAMap, style.macdStyle.L);
    if (ema26 == null) {
      return null;
    }
    double dif = ema12 - ema26;
    difMap[candleData.index] = dif;
    if (candleData.index < style.macdStyle.S) {
      return null;
    }
    var point = UIOPoint(
      candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
      dif,
      index: candleData.index,
    );
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
  @mustCallSuper
  void initState() {
    super.initState();
  }

  ///
  double ema(ExtCandleData candleData, Map<int, double> map, int n) {
    double preEMA = 0;
    if (candleData.index == 0) {
      double ema1 = candleData.close;
      map[0] = ema1;
      return map[0];
    }
    if (candleData.index > 0) {
      preEMA = map[candleData.index - 1];
      map[candleData.index] =
          preEMA * (n - 1) / (n + 1) + candleData.close * 2 / (n + 1);
      return map[candleData.index];
    }
    return null;
  }
}

class MACDWidgetState extends State<MACDWidget> with SingleTickerProviderStateMixin{
  AABBContext aabbContext;
  CandlesticksContext candlesticksContext;
  Paint positivePainter;
  Paint negativePainter;

  Map<int, double> shortEMAMap = <int, double>{};
  Map<int, double> longEMAMap = <int, double>{};
  Map<int, double> difMap = <int, double>{};
  Map<int, double> deaMap = <int, double>{};
  Map<int, double> macdMap = <int, double>{};
  double lastDif;
  double lastDea;
  double lastMacd;


  AnimationController _controller;
  Animation<MACDValueData> animationObject;
  Timer animationStartTimer;
  bool startAnimationShow = false;
  bool isShowClickData = false;//是否正在显示指定时间点的指标

  MACDValueData macdValueData = MACDValueData();


  ///
  void startAnimation(){
    if(animationStartTimer == null){
      animationStartTimer = Timer(const Duration(seconds: 2), (){
        startAnimationShow = true;
      });
    }
  }

  ///
  onMacdChange(int index,double dea, double dif, double macd) {
    startAnimation();

    MACDValueData begin = macdValueData.clone();

    macdValueData = MACDValueData();
    macdValueData.put(MACDValueKey.S, widget.style.macdStyle.S.toDouble());
    macdValueData.put(MACDValueKey.M, widget.style.macdStyle.M.toDouble());
    macdValueData.put(MACDValueKey.L, widget.style.macdStyle.L.toDouble());

    lastDea = dea;
    lastDif = dif;
    lastMacd = macd;
    if (candlesticksContext.extCandleData == null) {
      macdValueData.put(MACDValueKey.DEA, dea);
      macdValueData.put(MACDValueKey.DIF, dif);
      macdValueData.put(MACDValueKey.MACD, macd);

      if(startAnimationShow){
        animationObject = null;
        _controller.reset();
        animationObject = Tween(begin: begin,end: macdValueData).animate(_controller);
        animationObject.addListener((){
          setState(() {});
        });
        _controller.forward();
      }
    } else {
      animationObject = null;
      _controller?.stop();
    }
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aabbContext = AABBContext.of(context);
    candlesticksContext = CandlesticksContext.of(context);
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = aabbContext?.uiCamera;
    setThisPositionMacd();
    return MACDContext(
      onMacdChange: onMacdChange,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: UIAnimatedWidget<UIOCandles, UIOCandle>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.candlesStyle.duration,
              state: () => MacdCandlesView(
                    positivePainter: positivePainter,
                    negativePainter: negativePainter,
                    style: widget.style,
                    shortEMAMap: shortEMAMap,
                    longEMAMap: longEMAMap,
                    difMap: difMap,
                    deaMap: deaMap,
                    macdMap: macdMap,
                  ),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.candlesStyle.duration,
              state: () => DIFView(
                    style: widget.style,
                    shortEMAMap: shortEMAMap,
                    longEMAMap: longEMAMap,
                    difMap: difMap,
                    deaMap: deaMap,
                    macdMap: macdMap,
                    color: widget.style.maStyle.longColor,
                  ),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.candlesStyle.duration,
              state: () => DEAView(
                    style: widget.style,
                    shortEMAMap: shortEMAMap,
                    longEMAMap: longEMAMap,
                    difMap: difMap,
                    deaMap: deaMap,
                    macdMap: macdMap,
                    color: widget.style.maStyle.shortColor,
                  ),
            ),
          ),
          Positioned.fill(
            child: MACDValueWidget(
              macdValueData: animationObject?.value ?? macdValueData,
              style: widget.style,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 500));

    positivePainter = new Paint()
      ..color = widget.style.candlesStyle.positiveColor
      ..style = PaintingStyle.fill;
    negativePainter = new Paint()
      ..color = widget.style.candlesStyle.negativeColor
      ..style = PaintingStyle.fill;
  }

  @override
  void dispose() {
    _controller?.dispose();
    animationStartTimer?.cancel();
    animationStartTimer = null;
    super.dispose();
  }



  void setThisPositionMacd(){
    if (candlesticksContext.extCandleData == null && isShowClickData) {
      isShowClickData = false;
      if (lastDea != null) {
        macdValueData.put(MACDValueKey.DEA, lastDea);
      } else {
        macdValueData.remove(MACDValueKey.DEA);
      }
      if (lastDif != null) {
        macdValueData.put(MACDValueKey.DIF, lastDif);
      } else {
        macdValueData.remove(MACDValueKey.DIF);
      }
      if (lastMacd != null) {
        macdValueData.put(MACDValueKey.MACD, lastMacd);
      } else {
        macdValueData.remove(MACDValueKey.MACD);
      }
      if(mounted){
        setState(() {
          animationObject = null;
        });
      }
    } else if (candlesticksContext != null &&
        candlesticksContext.extCandleData != null) {
      isShowClickData = true;
      if (deaMap.containsKey(candlesticksContext.extCandleData.index)) {
        macdValueData.put(
            MACDValueKey.DEA, deaMap[candlesticksContext.extCandleData.index]);
      } else {
        macdValueData.remove(MACDValueKey.DEA);
      }
      if (difMap.containsKey(candlesticksContext.extCandleData.index)) {
        macdValueData.put(
            MACDValueKey.DIF, difMap[candlesticksContext.extCandleData.index]);
      } else {
        macdValueData.remove(MACDValueKey.DIF);
      }
      if (macdMap.containsKey(candlesticksContext.extCandleData.index)) {
        macdValueData.put(MACDValueKey.MACD,
            macdMap[candlesticksContext.extCandleData.index]);
      } else {
        macdValueData.remove(MACDValueKey.MACD);
      }
      if(mounted){
        setState(() {});
      }
    }

  }
}

class MACDWidget extends StatefulWidget {
  MACDWidget({
    Key key,
    this.dataStream,
    this.style,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;

  @override
  MACDWidgetState createState() => MACDWidgetState();
}
