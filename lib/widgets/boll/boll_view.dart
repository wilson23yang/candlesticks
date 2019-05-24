import 'dart:async';

import 'package:candlesticks/utils/string_util.dart';
import 'package:candlesticks/widgets/boll/boll_context.dart';
import 'package:candlesticks/widgets/boll/boll_value_data.dart';
import 'package:candlesticks/widgets/boll/boll_value_widget.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
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
  Map<int, double> bollMap;
  Map<int, double> curMap;

  BollView(this.type, this.bollLine, this.color, this.bollMap, {this.curMap})
      : super(animationCount: 2) {
    this._values = List<double>();

    painter = new Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
  }

  double maAverage(int index, int n) {
    if ((this._values == null) || (_values.length < n) || index < N) {
      return null;
    }
    //print(_values.sublist(index - N, index));
    double nSum = _values.sublist(index - N, index).reduce((a, b) {
      return a + b;
    });

    return nSum / N;
  }

  double _md(double ma, int index) {
    if ((this._values == null) || index < N) {
      return null;
    }
    List<double> subValues = _values.sublist(index - N + 1, index);
    List<double> dd = [];
    subValues.forEach((c) {
      dd.add(pow(c - ma, 2));
    });
    return sqrt(dd.reduce((a, b) {
          return a + b;
        }) /
        N);
  }

  @override
  UIOPoint getCandle(ExtCandleData candleData) {
    if (candleData == null) {
      return null;
    }
    if (type == Type.price) {
      if (candleData.index == _values.length - 1) {
        _values.last = candleData.close;
      } else {
        _values.add(candleData.close);
      }
    } else {
      _values.add(candleData.volume);
    }
    //print('----candleData.index------------${candleData.index}      ${_values.length}');
    if (_values.length < N) {
      return null;
    }

    double y;
    double ma = maAverage(candleData.index, N);
    if (ma == null) {
      return null;
    }
    double md = _md(ma, candleData.index);
    if (md == null) {
      return null;
    }
    double MB = maAverage(candleData.index - 1, N);
    if (MB == null) {
      return null;
    }
    if (bollLine == BollLine.MB) {
      y = MB;
    } else if (bollLine == BollLine.UP) {
      y = MB + P * md;
    } else if (bollLine == BollLine.DN) {
      y = MB - P * md;
    }
    var point = UIOPoint(
        candleData.timeMs.toDouble() + candleData.durationMs.toDouble() / 2.0,
        y,
        index: candleData.index);
    bollContext.onBollChange(bollLine, y, candleData.close);
    if (bollMap != null) {
      bollMap[candleData.index] = y;
    }
    if (curMap != null) {
      curMap[candleData.index] = candleData.close;
    }
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
    bollContext = BollContext.of(context);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class BollWidgetState extends State<BollWidget>
    with SingleTickerProviderStateMixin {
  AABBContext aabbContext;
  CandlesticksContext candlesticksContext;

  AnimationController _controller;
  Animation<BollValueData> animationObject;
  Timer _animationStartTimer;
  bool startAnimationShow = false;
  bool isShowClickData = false; //是否正在显示指定时间点的指标

  BollValueData bollValueData;

  Map<int, double> curMap = <int, double>{};
  Map<int, double> mbMap = <int, double>{};
  Map<int, double> upMap = <int, double>{};
  Map<int, double> dnMap = <int, double>{};

  double lastCur;
  double lastMb;
  double lastUp;
  double lastDn;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
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
  void startAnimation() {
    if (_animationStartTimer == null) {
      _animationStartTimer = Timer(const Duration(seconds: 2), () {
        startAnimationShow = true;
      });
    }
  }

  bool updateMB = false;
  bool updateUP = false;
  bool updateDN = false;
  BollValueData begin;
  int precision = 1;

  onBollChange(BollLine type, double boll, double currentValue) {
    startAnimation();
    precision = StringUtil.getPrecision(currentValue, defaultPrecision: 1);
    if (bollValueData == null) {
      bollValueData = BollValueData();
    }
    if (!updateMB && !updateUP && !updateDN) {
      begin = bollValueData.clone();
    }
    lastCur = currentValue;
    if (type == BollLine.MB) {
      lastMb = boll;
    } else if (type == BollLine.UP) {
      lastUp = boll;
    } else if (type == BollLine.DN) {
      lastDn = boll;
    }
    if (candlesticksContext == null ||
        candlesticksContext.extCandleData == null) {
      if (type == BollLine.MB && !updateMB) {
        if (startAnimationShow) {
          updateMB = true;
        }
        bollValueData = bollValueData.clone()
          ..currentValue = currentValue
          ..bollValue = boll;
      } else if (type == BollLine.UP && !updateUP) {
        if (startAnimationShow) {
          updateUP = true;
        }
        bollValueData = bollValueData.clone()
          ..currentValue = currentValue
          ..ubValue = boll;
      } else if (type == BollLine.DN && !updateDN) {
        if (startAnimationShow) {
          updateDN = true;
        }
        bollValueData = bollValueData.clone()
          ..currentValue = currentValue
          ..lbValue = boll;
      }

      if (startAnimationShow && updateMB && updateUP && updateDN) {
        animationObject = null;
        _controller.reset();
        animationObject =
            Tween(begin: begin, end: bollValueData).animate(_controller);
        animationObject.addListener(() {
          setState(() {});
        });
        _controller.forward();
        updateMB = false;
        updateUP = false;
        updateDN = false;
      }
    } else {
      if(mounted){
        setState(() {
          animationObject = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = aabbContext?.uiCamera;
    setThisPositionBoll();
    return BollContext(
        onBollChange: onBollChange,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.maStyle.duration,
              state: () => BollView(widget.type, BollLine.UP,
                  widget.style.maStyle.shortColor, upMap,
                  curMap: curMap),
            )),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.maStyle.duration,
              state: () => BollView(widget.type, BollLine.MB,
                  widget.style.maStyle.middleColor, mbMap),
            )),
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
              dataStream: widget.dataStream,
              uiCamera: uiCamera,
              duration: widget.style.maStyle.duration,
              state: () => BollView(widget.type, BollLine.DN,
                  widget.style.maStyle.longColor, dnMap),
            )),
            Positioned.fill(
                child: BollValueWidget(
              precision: precision,
              bollValueData: animationObject?.value ?? bollValueData,
              style: widget.style,
              type: widget.type,
            )),
          ],
        ));
  }

  void setThisPositionBoll() {
    if (candlesticksContext == null ||
        candlesticksContext.extCandleData == null && isShowClickData) {
      isShowClickData = false;
      bollValueData = BollValueData(
        bollValue: lastMb,
        currentValue: lastCur,
        ubValue: lastUp,
        lbValue: lastDn,
      );
      if (mounted) {
        setState(() {
          animationObject = null;
        });
      }
    } else if (candlesticksContext != null &&
        candlesticksContext.extCandleData != null) {
      isShowClickData = true;
      bollValueData = BollValueData(
        bollValue: mbMap[candlesticksContext.extCandleData.index],
        currentValue: curMap[candlesticksContext.extCandleData.index],
        ubValue: upMap[candlesticksContext.extCandleData.index],
        lbValue: dnMap[candlesticksContext.extCandleData.index],
      );
      if (mounted) {
        setState(() {
          animationObject = null;
        });
      }
    }
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

enum BollLine { MB, UP, DN }
