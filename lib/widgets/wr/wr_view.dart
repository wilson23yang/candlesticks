import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
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

class WrView extends UIAnimatedView<UIOPath, UIOPoint> {
  List<double> _Hvalues;
  List<double> _Lvalues;
  Paint painter;
  Color color;
  int period = 20;
  Map<int, double> wrMap;

  WrContext wrContext;

  WrView({@required this.color, @required this.period, @required this.wrMap})
      : super(animationCount: 2) {
    this._Hvalues = List<double>();
    this._Lvalues = List<double>();

    painter = new Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
  }

  ///
  double getHigh(int period) {
    List<double> sub =
        _Hvalues.sublist(_Hvalues.length - period, _Hvalues.length);
    sub.sort();
    //print('getHigh sub list:$sub                ${sub.last}');
    return sub.last;
  }

  ///
  double getLow(int period) {
    List<double> sub =
        _Lvalues.sublist(_Lvalues.length - period, _Lvalues.length);
    sub.sort();
    //print('getLow sub list:$sub                ${sub.first}');
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
    if (h - l == 0) {
      return null;
    }
    double y = 100 * (h - c) / (h - l);
    //print('wr---------$y     ${(h - c)}    $h      $c       ${(h-l)}');
    if (y == null) {
      return null;
    }
    var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        y,
        index: candleData.index);
    wrContext.onWrChange(period, y);
    wrMap[candleData.index] = y;
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
  AABBContext aabbContext;
  CandlesticksContext candlesticksContext;
  Map<int, double> wrShort = <int, double>{};
  Map<int, double> wrMiddle = <int, double>{};
  Map<int, double> wrLong = <int, double>{};
  var lastWrShort;
  var lastWrMiddle;
  var lastWrLong;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aabbContext = AABBContext.of(context);
    candlesticksContext = CandlesticksContext.of(context);
  }

  WrValueData wrValueData = WrValueData();

  onWrChange(int period, double wr) {
    if(widget.style.wrStyle.shortPeriod == period){
      lastWrShort = wr;
    }
    if(widget.style.wrStyle.middlePeriod == period){
      lastWrMiddle = wr;
    }
    if(widget.style.wrStyle.longPeriod == period){
      lastWrLong = wr;
    }
    if (candlesticksContext?.extCandleData != null) {
      return;
    }
    wrValueData.put(period, wr);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    setThisPositionWr();
    var uiCamera = aabbContext?.uiCamera;
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
                    wrMap: wrShort,
                  ),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.wrStyle.duration,
              state: () => WrView(
                    color: widget.style.wrStyle.middleColor,
                    period: widget.style.wrStyle.middlePeriod,
                    wrMap: wrMiddle,
                  ),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.wrStyle.duration,
              state: () => WrView(
                    color: widget.style.wrStyle.longColor,
                    period: widget.style.wrStyle.longPeriod,
                    wrMap: wrLong,
                  ),
            ),
          ),
          Positioned.fill(
            child: WrValueWidget(
              wrValueData: wrValueData,
              style: widget.style,
            ),
          ),
        ],
      ),
    );
  }


  ///设置指定时间点的Wr
  void setThisPositionWr(){
    if (candlesticksContext?.extCandleData != null) {
      if(wrShort.containsKey(candlesticksContext.extCandleData.index)){
        wrValueData.put(widget.style.wrStyle.shortPeriod, wrShort[candlesticksContext.extCandleData.index]);
      } else {
        wrValueData.remove(widget.style.wrStyle.shortPeriod);
      }
      if(wrMiddle.containsKey(candlesticksContext.extCandleData.index)){
        wrValueData.put(widget.style.wrStyle.middlePeriod, wrMiddle[candlesticksContext.extCandleData.index]);
      } else {
        wrValueData.remove(widget.style.wrStyle.middlePeriod);
      }
      if(wrLong.containsKey(candlesticksContext.extCandleData.index)){
        wrValueData.put(widget.style.wrStyle.longPeriod, wrLong[candlesticksContext.extCandleData.index]);
      } else {
        wrValueData.remove(widget.style.wrStyle.longPeriod);
      }
    } else {
      if(lastWrShort != null){
        wrValueData.put(widget.style.wrStyle.shortPeriod, lastWrShort);
      } else {
        wrValueData.remove(widget.style.wrStyle.shortPeriod);
      }
      if(lastWrMiddle != null){
        wrValueData.put(widget.style.wrStyle.middlePeriod, lastWrMiddle);
      } else {
        wrValueData.remove(widget.style.wrStyle.middlePeriod);
      }
      if(lastWrLong != null){
        wrValueData.put(widget.style.wrStyle.longPeriod, lastWrLong);
      } else {
        wrValueData.remove(widget.style.wrStyle.longPeriod);
      }
    }
    setState(() {});
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
