import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/treedlist.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/2d/uiobject.dart';


const ZERO = 0.00000001;

abstract class AABBState extends State<AABBWidget>
    with TickerProviderStateMixin {

  TreedListMin<double> uiCandlesMaxY = TreedListMin(null, reverse: -1);
  TreedListMin<double> uiCandlesMinY = TreedListMin(null);

  TreedListMin<double> uiObjectsMaxY = TreedListMin(null, reverse: -1);
  TreedListMin<double> uiObjectsMinY = TreedListMin(null);
  StreamSubscription<CandleData> subscription;
  CandlesticksContext candlesticksContext;
  StreamController<ExtCandleData> exDataStreamController;
  Stream<ExtCandleData> exDataStream;
  List<ExtCandleData> candleDataList = List<ExtCandleData>(); //这个可以优化掉。


  AABBState() : super();


  onCandleData(ExtCandleData candleData) {
    if (candleData.first) {
      this.uiObjectsMaxY.add(double.negativeInfinity);
      this.uiObjectsMinY.add(double.infinity);

      this.uiCandlesMaxY.add(double.negativeInfinity);
      this.uiCandlesMinY.add(double.infinity);
    }
    exDataStreamController.sink.add(candleData);
  }

  onAABBChange(ExtCandleData candleData, UIObject uiobject) {
    var uiObjectAABB = uiobject.aabb();
    this.uiObjectsMinY.update(candleData.index, uiObjectAABB.min.y);
    this.uiObjectsMaxY.update(candleData.index, uiObjectAABB.max.y);

    if (uiobject is UIOCandle) {
      var aabb = uiobject.aabb();
      this.uiCandlesMinY.update(candleData.index, aabb.min.y);
      this.uiCandlesMaxY.update(candleData.index, aabb.max.y);

      if (candleData.first) {
        this.candleDataList.add(candleData);
      }
    }

    candlesticksContext.onCandleDataFinish(candleData);
  }

  ExtCandleData getExtCandleDataIndex(int index) {
    if ((candleDataList == null) || (index < 0) ||
        (index >= this.candleDataList.length)) {
      return null;
    }
    return this.candleDataList[index];
  }

  ExtCandleData getExtCandleDataIndexByX(double x) {
    var index = getCandleIndexByX(x);
    return getExtCandleDataIndex(index);
  }

  int getCandleIndexByX(double x) {
    var candlesX = candlesticksContext.candlesX;

    var baseX = candlesX.first;
    int xIndex = (x - baseX) ~/ widget.durationMs;
    if (xIndex >= candlesX.length) {
      xIndex = candlesX.length - 1;
    }
    if (xIndex < 0) {
      xIndex = 0;
    }
    return xIndex;
  }

  UIOPoint getMinPoint() {
    if ((widget.rangeX == null) || (widget.rangeX.maxX == null) ||
        (widget.rangeX.minX == null)) {
      return null;
    }
    var candlesX = candlesticksContext.candlesX;
    var baseX = candlesX.first;
    var startIndex = getCandleIndexByX(widget.rangeX.minX);
    var endIndex = getCandleIndexByX(widget.rangeX.maxX);
    var minIndex = this.uiCandlesMinY.minIndex(startIndex, endIndex);
    return UIOPoint(
        baseX + minIndex * widget.durationMs + widget.durationMs / 2,
        uiCandlesMinY.get(minIndex));
  }

  UIOPoint getMaxPoint() {
    if ((widget.rangeX == null) || (widget.rangeX.maxX == null) ||
        (widget.rangeX.minX == null)) {
      return null;
    }
    var candlesX = candlesticksContext.candlesX;
    var baseX = candlesX.first;
    var startIndex = getCandleIndexByX(widget.rangeX.minX);
    var endIndex = getCandleIndexByX(widget.rangeX.maxX);
    var minIndex = this.uiCandlesMaxY.minIndex(startIndex, endIndex);
    return UIOPoint(
        baseX + minIndex * widget.durationMs + widget.durationMs / 2,
        uiCandlesMaxY.get(minIndex));
  }

  UICamera calUICamera(double minX, double maxX, double paddingY) {
    var candlesX = candlesticksContext.candlesX;

    if ((candlesX.length <= 0) || (minX == null) || (maxX == null)) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }
    if (widget.durationMs <= 0) {
      return UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
    }

    int startIndex = getCandleIndexByX(minX);
    int endIndex = candlesX.length - 1;


    var minY = this.uiObjectsMinY.min(startIndex, endIndex);
    if (minY == null) {
      return null;
    }
    var maxY = this.uiObjectsMaxY.min(startIndex, endIndex);
    if (maxY == null) {
      return null;
    }

    var topPadding = (maxY - minY) * paddingY;
    var realMinY = minY - topPadding * paddingY * 3;
    var realMaxY = maxY + topPadding + topPadding * paddingY * 3;

    ///解决中间数据不变同导至viewport高度0时，导至point顠出canvas绘制区引起页面卡顿
    if(realMinY == realMaxY){
      realMinY = realMinY - realMinY * 0.1;
      realMaxY = realMaxY + realMaxY * 0.1;
    }

    return UICamera(
        UIORect(UIOPoint(minX, realMinY), UIOPoint(maxX, realMaxY)));
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //插入监听器
    subscription = widget.extDataStream.listen(onCandleData);
    exDataStreamController = new StreamController<ExtCandleData>();
    exDataStream = exDataStreamController.stream.asBroadcastStream();
  }

  @override void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    candlesticksContext = CandlesticksContext.of(context);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {
    subscription.cancel();
    exDataStreamController.close();

    super.dispose(); //删除监听器
  }
}
