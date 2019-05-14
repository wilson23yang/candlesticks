import 'package:candlesticks/widgets/graticule/net_grid_widget.dart';
import 'package:candlesticks/widgets/mh/mh_volume_view.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';

class MhMiddleWidget extends StatelessWidget {

  int middleDuration;
  double newDuration;

  MhMiddleWidget({
    Key key,
    Stream<ExtCandleData> extDataStream,
    this.candlesticksStyle,
    this.rangeX,
    this.durationMs,
  }) : super(key: key) {


    this.volumeDataStream = extDataStream.map((ExtCandleData extCandleData) {

      if(middleDuration == null || newDuration == null){
        middleDuration = extCandleData.durationMs~/2 - extCandleData.durationMs~/10;
        newDuration = extCandleData.durationMs/5;
      }

      double open = extCandleData.volume;
      double close = 0;
      if (extCandleData.open <= extCandleData.close) {
        close = extCandleData.volume;
        open = 0;
      }
      CandleData candleData = CandleData(
          timeMs: extCandleData.timeMs + middleDuration,
          open: open,
          close: close,
          high: extCandleData.volume,
          low: 0,
          volume: extCandleData.volume);
      return ExtCandleData(
        candleData,
        durationMs: newDuration,
        first: extCandleData.first,
        index: extCandleData.index,
        getValue: (candleData) => candleData.volume,
      );
    });
  }

  Stream<ExtCandleData> volumeDataStream;
  final CandlesticksStyle candlesticksStyle;
  final AABBRangeX rangeX;
  final double durationMs;

  @override
  Widget build(BuildContext context) {
    var widget = this;
    return AABBWidget(
      extDataStream: volumeDataStream,
      durationMs: durationMs,
      rangeX: rangeX,
      candlesticksStyle: widget.candlesticksStyle,
      paddingY: 0,
      child: Container(
        decoration: BoxDecoration(
          color: widget.candlesticksStyle.backgroundColor,
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: NetGridWidget(
                  candlesticksStyle: widget.candlesticksStyle,
                  hideTopLine: true,
                )),
            Positioned.fill(
              child: MhVolumeWidget(
                dataStream: widget.volumeDataStream,
                style: widget.candlesticksStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
