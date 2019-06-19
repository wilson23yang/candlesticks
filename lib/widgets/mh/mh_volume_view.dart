import 'dart:async';

import 'package:candlesticks/utils/string_util.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/mh/mh_volume_context.dart';
import 'package:candlesticks/widgets/mh/mh_volume_value_view.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_candles.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class MhVolumeView extends UIAnimatedView<UIOCandles, UIOCandle> {
  final CandlesticksStyle style;
  Paint positivePainter;
  Paint negativePainter;

  MhVolumeContext mhVolumeContext;

  MhVolumeView({this.positivePainter, this.negativePainter, this.style})
      : super(animationCount: 2);

  @override
  UIOCandle getCandle(ExtCandleData candleData) {
    var candleUIObject = UIOCandle.fromData(candleData, 0,
        candleData.open <= candleData.close ? positivePainter : negativePainter,
        index: candleData.index);
    mhVolumeContext.onVolChange(candleData.index,candleData.volume);
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
    mhVolumeContext = MhVolumeContext.of(context);
  }
}

class MhVolumeWidgetState extends State<MhVolumeWidget> with SingleTickerProviderStateMixin{
  AABBContext aabbContext;
  CandlesticksContext candlesticksContext;
  Paint positivePainter;

  AnimationController _controller;
  Animation<double> animationObject;
  Timer _animationStartTimer;
  bool startAnimationShow = false;
  bool isShowClickData = false;//是否正在显示指定时间点的指标

  double lastVol;
  double vol;
  double begin = 0;
  int precision = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 500));
    positivePainter = new Paint()
      ..color = widget.style.mhStyle.volumeLineColor
      ..style = PaintingStyle.fill;
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

  int lastIndex = -1;//用于判断K切换
  void onVolChange(int index, double volume){
    startAnimation();
    begin = (index != lastIndex) ? 0 : vol;
    lastIndex = index;
    lastVol = volume;
    precision = StringUtil.getPrecision(lastVol,defaultPrecision: 1);
    if(candlesticksContext?.touchPointCandleData == null){
      vol = lastVol;
      if(startAnimationShow){
        animationObject = null;
        _controller.reset();
        animationObject = Tween(begin: begin,end: vol).animate(_controller);
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
  Widget build(BuildContext context) {
    var uiCamera = aabbContext?.uiCamera;
    if(candlesticksContext != null &&
        candlesticksContext.touchPointCandleData != null){
      isShowClickData = true;
      vol = candlesticksContext?.touchPointCandleData?.volume;
      if(mounted){
        setState(() {});
      }
    } else if (candlesticksContext.touchPointCandleData == null && isShowClickData){
      isShowClickData = false;
      vol = lastVol;
      if(mounted){
        setState(() {
          animationObject = null;
        });
      }
    }
    return MhVolumeContext(
      onVolChange: onVolChange,
      child: Stack(children: <Widget>[
        Positioned.fill(
          top: 15,
          child: UIAnimatedWidget<UIOCandles, UIOCandle>(
            dataStream: widget.dataStream,
            uiCamera: uiCamera,
            duration: widget.style.candlesStyle.duration,
            state: () => MhVolumeView(
              positivePainter: positivePainter,
              negativePainter: positivePainter,
              style: widget.style,
            ),
          ),
        ),
        Positioned.fill(
          child: MhVolumeValueWidget(
            precision:precision,
            vol: animationObject?.value ?? vol,
            style: widget.style,
          ),
        ),
      ]),
    );
  }

}

class MhVolumeWidget extends StatefulWidget {
  MhVolumeWidget({
    Key key,
    this.dataStream,
    this.style,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;

  @override
  MhVolumeWidgetState createState() => MhVolumeWidgetState();
}
