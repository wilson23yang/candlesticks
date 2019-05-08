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

  RsiContext rsiContext;

  RsiView({this.color, this.period}) : super(animationCount: 2) {
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

    if(gain.abs() + decline.abs() == 0){
      return null;
    }

    double y = gain * 100 / (gain.abs() + decline.abs());
    if(y == null){
      return null;
    }
    var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        y,
        index: candleData.index);
    rsiContext.onRsiChange(period,y);
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

class RsiWidgetState extends State<RsiWidget> {
  AABBContext candlesticksContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  RsiValueData rsiValueData = RsiValueData();

  onRsiChange(int period, double rsi) {
    rsiValueData.put(period, rsi);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = candlesticksContext?.uiCamera;
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
                  ),
            )),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.rsiStyle.duration,
              state: () => RsiView(
                    color: widget.style.rsiStyle.middleColor,
                    period: widget.style.rsiStyle.middlePeriod,
                  ),
            )),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.rsiStyle.duration,
              state: () => RsiView(
                    color: widget.style.rsiStyle.longColor,
                    period: widget.style.rsiStyle.longPeriod,
                  ),
            )),
            Positioned.fill(
                child: RsiValueWidget(
              rsiValueData: rsiValueData,
              style: widget.style,
            )),
          ],
        ));
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
