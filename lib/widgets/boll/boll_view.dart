import 'package:candlesticks/widgets/boll/boll_context.dart';
import 'package:candlesticks/widgets/boll/boll_value_data.dart';
import 'package:candlesticks/widgets/boll/boll_value_widget.dart';
import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'dart:math';


class BollView extends UIAnimatedView<UIOPath, UIOPoint> {
  List<double> _values;
  Type type;
  BollLine bollLine;
  Paint painter;
  Color color;
  static const int N = 20;
  static const int P = 2;

  BollContext bollContext;

  BollView(this.type, this.bollLine, this.color) : super(animationCount: 2) {
    this._values = List<double>();

    painter = new Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
  }

  double maAverage(int index, int n) {
    if ((this._values == null) || (_values.length < n) || index < N) {
      return null;
    }
    //print(_values.sublist(index - N, index));
    double nSum = _values.sublist(index - N, index).reduce((a,b){
      return a+b;
    });

    return nSum/N;
  }

  double _md(double ma,int index){
    if ((this._values == null) || index < N) {
      return null;
    }
    List<double> subValues = _values.sublist(index - N + 1, index);
    List<double> dd = [];
    subValues.forEach((c){
      dd.add(pow(c - ma, 2));
    });
    return sqrt(dd.reduce((a,b){
      return a + b;
    })/N);
  }


  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    if(candleData == null){
      return null;
    }
    if(type == Type.price){
      if(candleData.index == _values.length - 1){
        _values.last = candleData.close;
      } else {
        _values.add(candleData.close);
      }
    } else {
      _values.add(candleData.volume);
    }
    //print('----candleData.index------------${candleData.index}      ${_values.length}');
    if(_values.length < N){
      return null;
    }

    double y;
    double ma = maAverage(candleData.index, N);
    if(ma == null){
      return null;
    }
    double md = _md(ma, candleData.index);
    if(md == null){
      return null;
    }
    double MB = maAverage(candleData.index-1, N);
    if(MB == null){
      return null;
    }
    if(bollLine == BollLine.MB){
      y = MB;
    } else if(bollLine == BollLine.UP){
      y = MB + P * md;
    } else if(bollLine == BollLine.DN){
      y = MB - P * md;
    }
    var point = UIOPoint(candleData.timeMs.toDouble() +
          candleData.durationMs.toDouble() / 2.0, y, index: candleData.index);
    bollContext.onBollChange(bollLine,y,candleData.close);
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

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    bollContext = BollContext.of(context);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class BollWidgetState extends State<BollWidget> {

  AABBContext candlesticksContext;

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  BollValueData bollValueData;

  onBollChange(BollLine type,double boll, double currentValue) {
    if (bollValueData == null) {
      bollValueData = BollValueData();
    }
    if(type == BollLine.MB){
      bollValueData = BollValueData(bollValue: boll,currentValue: currentValue,ubValue: bollValueData.ubValue,lbValue: bollValueData.lbValue);
    } else if(type == BollLine.UP){
      bollValueData = BollValueData(bollValue: bollValueData.bollValue,currentValue: currentValue,ubValue: boll,lbValue: bollValueData.lbValue);
    } else if(type == BollLine.DN){
      bollValueData = BollValueData(bollValue: bollValueData.bollValue,currentValue: currentValue,ubValue: bollValueData.ubValue,lbValue: boll);
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = candlesticksContext?.uiCamera;
    return BollContext(
        onBollChange: onBollChange,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.maStyle.duration,
                  state: () =>
                      BollView(widget.type, BollLine.UP, widget.style.maStyle.shortColor),
                )
            ),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.maStyle.duration,
                  state: () =>
                      BollView(widget.type, BollLine.MB, widget.style.maStyle.middleColor),
                )
            ),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: widget.style.maStyle.duration,
                  state: () =>
                      BollView(widget.type, BollLine.DN, widget.style.maStyle.longColor),
                )
            ),
            Positioned.fill(
                child: BollValueWidget(
                  bollValueData: bollValueData,
                  style: widget.style,
                  type: widget.type,
                )
            ),

          ],
        ));
  }
}


class BollWidget extends StatefulWidget {
  BollWidget({
    Key key,
    this.dataStream,
    this.style,
    this.type,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;
  final Type type;

  @override
  BollWidgetState createState() => BollWidgetState();
}

enum BollLine{
  MB,UP,DN
}
