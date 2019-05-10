import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/kdj/kdj_context.dart';
import 'package:candlesticks/widgets/kdj/kdj_value_data.dart';
import 'package:candlesticks/widgets/kdj/kdj_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class KdjView extends UIAnimatedView<UIOPath, UIOPoint> {
  List<double> _Hvalues;
  List<double> _Lvalues;
  List<double> _KValues;
  List<double> _DValues;
  Map<int, double> kdjMap;
  Paint painter;
  Color color;
  final KDJ kdj;
  int period = 14;
  int m1 = 1;
  int m2 = 3;

  KdjContext kdjContext;

  KdjView({this.color, this.period, this.kdj, @required this.kdjMap})
      : super(animationCount: 2) {
    this._Hvalues = List<double>();
    this._Lvalues = List<double>();
    this._KValues = List<double>();
    this._DValues = List<double>();

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

  ///第N-1的D值
  double getDValueN_1(int index) {
    if (_DValues.length > 1 && _DValues.length - 1 >= index) {
      return _DValues[index - 1];
    }
    return 50;
  }

  ///第N-1的K值
  double getKValueN_1(int index) {
    if (_KValues.length > 1 && _KValues.length - 1 >= index) {
      return _KValues[index - 1];
    }
    return 50;
  }

  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    //print('index:${candleData.index}');
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
      _DValues.add(50);
      _KValues.add(50);
    }

    if (candleData.index == _Hvalues.length - 1) {
      _Hvalues.last = candleData.high;
    } else {
      _Hvalues.add(candleData.high);
    }
    if (_Hvalues.length < period || _Lvalues.length < period) {
      return null;
    }
    double c = candleData.close;
    double h = getHigh(period);
    double l = getLow(period);
    if (h - l == 0) {
      return null;
    }
    double rsv = (c - l) / (h - l) * 100;

    double curKValue = 2 * getKValueN_1(candleData.index) / 3 + rsv / 3;
    _KValues[candleData.index] = curKValue;

    double curDValue = 2 * getDValueN_1(candleData.index) / 3 + curKValue / 3;
    _DValues[candleData.index] = curDValue;

    double curJValue = 3 * curKValue - 2 * curDValue;

    //print('j=$curJValue   k=$curKValue   d=$curDValue    Kn-1(${candleData.index}):${getKValueN_1(candleData.index)}    Dn-1:${getDValueN_1(candleData.index)}');
    if (kdj == KDJ.J) {
      var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        curJValue,
        index: candleData.index,
      );
      kdjMap[candleData.index] = curJValue;
      kdjContext.onKdjChange(kdj, curJValue);
      return point;
    } else if (kdj == KDJ.K) {
      var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        curKValue,
        index: candleData.index,
      );
      kdjMap[candleData.index] = curKValue;
      kdjContext.onKdjChange(kdj, curKValue);
      return point;
    } else if (kdj == KDJ.D) {
      var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        curDValue,
        index: candleData.index,
      );
      kdjMap[candleData.index] = curDValue;
      kdjContext.onKdjChange(kdj, curDValue);
      return point;
    } else {
      return null;
    }
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
    kdjContext = KdjContext.of(context);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class KdjWidgetState extends State<KdjWidget> {
  AABBContext aabbContext;
  CandlesticksContext candlesticksContext;
  Map<int, double> kMap = <int, double>{};
  Map<int, double> dMap = <int, double>{};
  Map<int, double> jMap = <int, double>{};
  double lastK;
  double lastD;
  double lastJ;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aabbContext = AABBContext.of(context);
    candlesticksContext = CandlesticksContext.of(context);
  }

  KdjValueData kdjValueData = KdjValueData();

  onKdjChange(KDJ type, double kdj) {
    if(type == KDJ.K){
      lastK = kdj;
    } else if(type == KDJ.J){
      lastJ = kdj;
    } else {
      lastD = kdj;
    }
    if (candlesticksContext.extCandleData != null) {
      return;
    }
    kdjValueData.put(type, kdj);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = aabbContext?.uiCamera;
    if (candlesticksContext.extCandleData != null) {
      kdjValueData.put(KDJ.K, kMap[candlesticksContext.extCandleData.index]);
      kdjValueData.put(KDJ.D, dMap[candlesticksContext.extCandleData.index]);
      kdjValueData.put(KDJ.J, jMap[candlesticksContext.extCandleData.index]);
      setState(() {});
    } else {
      kdjValueData.put(KDJ.K, lastK);
      kdjValueData.put(KDJ.D, lastD);
      kdjValueData.put(KDJ.J, lastJ);
      setState(() {});
    }
    return KdjContext(
      onKdjChange: onKdjChange,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.kdjStyle.duration,
              state: () => KdjView(
                  color: widget.style.kdjStyle.jColor,
                  period: widget.style.kdjStyle.period,
                  kdjMap: jMap,
                  kdj: KDJ.J),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.kdjStyle.duration,
              state: () => KdjView(
                  color: widget.style.kdjStyle.kColor,
                  period: widget.style.kdjStyle.period,
                  kdjMap: kMap,
                  kdj: KDJ.K),
            ),
          ),
          Positioned.fill(
            child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.kdjStyle.duration,
              state: () => KdjView(
                  color: widget.style.kdjStyle.dColor,
                  period: widget.style.kdjStyle.period,
                  kdjMap: dMap,
                  kdj: KDJ.D),
            ),
          ),
          Positioned.fill(
            child: KdjValueWidget(
              kdjValueData: kdjValueData,
              style: widget.style,
            ),
          ),
        ],
      ),
    );
  }
}

class KdjWidget extends StatefulWidget {
  KdjWidget({
    Key key,
    this.dataStream,
    this.style,
    this.kdj,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;
  final KDJ kdj;

  @override
  KdjWidgetState createState() => KdjWidgetState();
}

enum KDJ { K, D, J }
