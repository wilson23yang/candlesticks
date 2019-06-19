import 'package:flutter/material.dart';
import 'dart:async';
import 'package:candlesticks/widgets/candlesticks_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';

const ZERO = 0.00000001;

abstract class CandlesticksState extends State<CandlesticksWidget>
    with TickerProviderStateMixin {
  CandleData firstCandleData;
  double durationMs;
  StreamController<ExtCandleData> exdataStreamController;
  Stream<ExtCandleData> exdataStream;
  List<double> candlesX = List<double>();
  AnimationController uiCameraAnimationController;
  Animation<AABBRangeX> uiCameraAnimation;
  StreamSubscription<CandleData> subscription;
  bool touching = false;
  List<ExtCandleData> candleDataList = List<ExtCandleData>(); //这个可以优化掉。
  bool isShowingEmptyPage = false;

  CandlesticksState({Stream<CandleData> dataStream})
      : super();

  bool isWaitingForInitData() {
    return this.candlesX.length < widget.candlesticksStyle.initAfterNData;
  }

  _onCandleData(CandleData candleData) {
    if(candleData == null){
      return;
    }
    if (candleDataList.length > 0) {
      if (candleData.timeMs - candleDataList.last.timeMs > this.durationMs) {
        CandleData t = CandleData(
          timeMs: (candleData.timeMs - this.durationMs).toInt(),
          open: candleDataList.last.close,
          close: candleDataList.last.close,
          high: candleDataList.last.close,
          low: candleDataList.last.close,
          volume: 0
        );
        _onCandleData(t);
      }
    }

    ///修复在durationMs时间内出现多个不同的时点
    if(candleData.timeMs % this.durationMs != 0 && this.durationMs <= 10080 * 1000 * 60){
      candleData = CandleData(
          timeMs: ((candleData.timeMs ~/ this.durationMs + 1) * this.durationMs).toInt(),
          open: candleData.open,
          close: candleData.close,
          high: candleData.high,
          low: candleData.low,
          volume: candleData.volume);
    }

    var first = false;
    if ((candlesX.length <= 0) || (candleData.timeMs > candlesX.last)) {
      candlesX.add(candleData.timeMs.toDouble());
      first = true;
    }

    var extCandleData = ExtCandleData(
        candleData, index: this.candlesX.length - 1,
        durationMs: this.durationMs, first: first);
    if(first){
      candleDataList.add(extCandleData);
    } else {
      candleDataList.last = extCandleData;
    }

    //print('extCandleData::::::index:${extCandleData.index}  first:${extCandleData.first}   candleDataList length:${candleDataList.length}');

    this.exdataStreamController.sink.add(extCandleData);
    if (!isWaitingForInitData() && isShowingEmptyPage) {
      isShowingEmptyPage = false;
      setState(() {

      });
    }
  }

  onCandleData(CandleData candleData) {
    if (firstCandleData == null) {
      firstCandleData = candleData;
      return;
    }

    if (this.durationMs == null) {
      this.durationMs = (candleData.timeMs - firstCandleData.timeMs).toDouble();
      _onCandleData(firstCandleData);
    }

    _onCandleData(candleData);
  }

  onCandleDataFinish(ExtCandleData candleData) {
    if (uiCameraAnimation == null) {
      var maxX = candlesX.last + durationMs;
      var minX = maxX - durationMs * widget.candlesticksStyle.defaultViewPortX;
      var rangeX = AABBRangeX(minX, maxX);
      uiCameraAnimation =
          Tween(begin: rangeX, end: rangeX).animate(
              uiCameraAnimationController);
      uiCameraAnimationController.reset();
      setState(() {

      });
    } else if ((!touching) && (!this.uiCameraAnimationController.isAnimating)) {
      var currentRangeX = this.uiCameraAnimation.value;
      if ((currentRangeX.minX <= candlesX.last) &&
          (candlesX.last <= currentRangeX.maxX + durationMs * 2)) {
        var maxX = candlesX.last + durationMs;
        var minX = maxX - currentRangeX.width;
        var rangeX = AABBRangeX(minX, maxX);
        uiCameraAnimation =
            Tween(begin: rangeX, end: rangeX).animate(
                uiCameraAnimationController);
        uiCameraAnimationController.reset();
        setState(() {

        });
      }
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if(candleDataList.length <= widget.candlesticksStyle.defaultViewPortX){
      return;
    }

    touching = false;
    //区间的最大值， 最小值。
    if (uiCameraAnimation == null) {
      return;
    }

    var currentRangeX = this.uiCameraAnimation.value;
    var width = currentRangeX.width;
    double a = width * 5;
    var viewPortDx = details.primaryVelocity.abs() / context.size.width;
    if (viewPortDx ~/ durationMs > 2) {
      viewPortDx = 2;
    }
    var worldDx = width * viewPortDx;

    double speed = worldDx; //per second
    double durationSecond = speed / a;
    double targetDx = speed * durationSecond +
        a * durationSecond * durationSecond / 2;
    if (details.primaryVelocity < 0) {
      targetDx = -targetDx;
    }

    double minX = currentRangeX.minX - targetDx;

    if (minX < this.candlesX.first) {
      minX = this.candlesX.first;
    }
    if (minX > this.candlesX.last + durationMs - width) {
      minX = this.candlesX.last + durationMs - width;
    }
    double maxX = minX + width;

    var newUICamera = AABBRangeX(minX, maxX);
    uiCameraAnimation =
        Tween(begin: currentRangeX, end: newUICamera)
            .animate(CurvedAnimation(
            parent: uiCameraAnimationController,
            curve: Curves.decelerate
        ));
    uiCameraAnimationController.reset();
    uiCameraAnimationController.forward();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if(candleDataList.length <= widget.candlesticksStyle.defaultViewPortX){
      return;
    }
    if (uiCameraAnimation == null) { //还没有初始化完成。
      return;
    }

    var dr = details.primaryDelta / context.size.width;
    var dx = uiCameraAnimation.value.width * dr;
    var rangeX = uiCameraAnimation.value;
    var minX = rangeX.minX;
    var maxX = rangeX.maxX;
    minX -= dx;
    maxX -= dx;
    var width = maxX - minX;

    if (minX < this.candlesX.first) {
      minX = this.candlesX.first;
      maxX = minX + width;
    }

    if (maxX > this.candlesX.last + this.durationMs + rangeX.width / 4) {
      maxX = this.candlesX.last + this.durationMs + rangeX.width / 4;
      minX = maxX - width;
    }

    var newRangeX = AABBRangeX(minX, maxX);

    uiCameraAnimation =
        Tween(begin: newRangeX, end: newRangeX).animate(
            uiCameraAnimationController);
    uiCameraAnimationController.reset();
    extCandleData = null;
    touchPoint = null;
    setState(() {

    });
  }

  double startX;
  AABBRangeX startRangeX;
  Offset startPosition;

  void handleScaleStart(ScaleStartDetails details) {
    if(candleDataList.length <= widget.candlesticksStyle.defaultViewPortX){
      return;
    }
    startPosition = details.focalPoint;
    startRangeX = uiCameraAnimation.value;

    RenderBox getBox = context.findRenderObject();
    startX = startRangeX.minX + (getBox
        .globalToLocal(details.focalPoint)
        .dx / context.size.width) * startRangeX.width;
    touching = true;
  }


  onScaleUpdate(ScaleUpdateDetails details) {
    if(candleDataList.length <= widget.candlesticksStyle.defaultViewPortX){
      return;
    }
    double scale = 1 / details.scale;
    /*
    var width = originWidth * scale;
    if (width > this.durationMs * widget.candlesticksStyle.maxViewPortX) {
      width = this.durationMs * widget.candlesticksStyle.maxViewPortX;
    }
    if (width < this.durationMs * widget.candlesticksStyle.minViewPortX) {
      width = this.durationMs * widget.candlesticksStyle.maxViewPortX;
    }
    */
    var width = startRangeX.width * scale;
    if (width < durationMs * this.widget.candlesticksStyle.minViewPortX) {
      width = durationMs * this.widget.candlesticksStyle.minViewPortX;
    }
    if (width > durationMs * this.widget.candlesticksStyle.maxViewPortX) {
      width = durationMs * this.widget.candlesticksStyle.maxViewPortX;
    }

    var dx = (startX - startRangeX.minX) * scale;

    double minX = startX - dx;
    double maxX = minX + width;
    if (minX < this.candlesX.first) {
      minX = this.candlesX.first;
      maxX = minX + width;
    }
    if (maxX > this.candlesX.last + this.durationMs) {
      maxX = this.candlesX.last + this.durationMs;
      minX = maxX - width;
    }
    var newRangeX = AABBRangeX(minX, maxX);

    uiCameraAnimation =
        Tween(begin: newRangeX, end: newRangeX).animate(
            uiCameraAnimationController);
    uiCameraAnimationController.reset();
    extCandleData = null;
    touchPoint = null;
    setState(() {

    });
  }

  ExtCandleData extCandleData;
  Offset touchPoint;

  onTapUp(TapUpDetails details) {
    RenderBox getBox = context.findRenderObject();
    var currentRangeX = uiCameraAnimation.value;
    touchPoint = getBox.globalToLocal(details.globalPosition);

    var worldX = currentRangeX.minX +
        (touchPoint.dx / context.size.width) * currentRangeX.width;
    var extDataIndex = (worldX - candlesX.first) ~/ durationMs;
    if (extDataIndex < 0) {
      return;
    }
    if (extDataIndex >= this.candleDataList.length) {
      return;
    }
    extCandleData = candleDataList[extDataIndex];
    setState(() {

    });
  }

  onTapDown(TapDownDetails details) {
    RenderBox getBox = context.findRenderObject();
    touchPoint = getBox.globalToLocal(details.globalPosition);
  }

  onLongPress() {
    var currentRangeX = uiCameraAnimation.value;
    var worldX = currentRangeX.minX +
        (touchPoint.dx / context.size.width) * currentRangeX.width;
    var extDataIndex = (worldX - candlesX.first) ~/ durationMs;
    if (extDataIndex < 0) {
      return;
    }
    if (extDataIndex >= this.candleDataList.length) {
      return;
    }
    extCandleData = candleDataList[extDataIndex];
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState(); //插入监听器
    firstCandleData = null;
    durationMs = widget.durationMs;
    exdataStreamController = new StreamController<ExtCandleData>();
    exdataStream = exdataStreamController.stream.asBroadcastStream();
    subscription = widget.dataStream.listen(onCandleData);
    uiCameraAnimationController = AnimationController(
        duration: widget.candlesticksStyle.cameraDuration, vsync: this);
    extCandleData = null;
    touchPoint = null;
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    subscription.cancel();
    exdataStreamController.close();
    uiCameraAnimationController.dispose();

    super.dispose(); //删除监听器
  }
}
