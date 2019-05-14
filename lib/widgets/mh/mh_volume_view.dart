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
    mhVolumeContext.onVolChange(candleData.volume);
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

class MhVolumeWidgetState extends State<MhVolumeWidget> {
  AABBContext aabbContext;
  CandlesticksContext candlesticksContext;
  Paint positivePainter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aabbContext = AABBContext.of(context);
    candlesticksContext = CandlesticksContext.of(context);
  }

  double lastVol;
  double vol;

  void onVolChange(double vol){
    lastVol = vol;
    if(candlesticksContext?.extCandleData == null){
      vol = lastVol;
      if(mounted){
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = aabbContext?.uiCamera;
    if(candlesticksContext?.extCandleData != null){
      vol = candlesticksContext?.extCandleData?.volume;
    } else {
      vol = lastVol;
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
            vol: vol,
            style: widget.style,
          ),
        ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    positivePainter = new Paint()
      ..color = widget.style.mhStyle.volumeLineColor
      ..style = PaintingStyle.fill;
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
