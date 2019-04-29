import 'package:candlesticks/widgets/graticule/graticule_net_widget.dart';
import 'package:candlesticks/widgets/indicator_switch.dart';
import 'package:candlesticks/widgets/rsi/rsi_view.dart';
import 'package:candlesticks/widgets/wr/wr_view.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';

class BottomWidget extends StatelessWidget {

  BottomWidget({
    Key key,
    this.extDataStream,
    this.candlesticksStyle,
    this.rangeX,
    this.durationMs,
  }) :super(key: key);

  final Stream<ExtCandleData> extDataStream;
  final CandlesticksStyle candlesticksStyle;
  final AABBRangeX rangeX;
  final double durationMs;

  @override
  Widget build(BuildContext context) {
    var widget = this;
    return Container(
        decoration: BoxDecoration(
          color: widget.candlesticksStyle.backgroundColor,
        ),
        child: Stack(
          children: <Widget>[
//                Positioned.fill(
//                    top: 12,
//                    child: CandlesWidget(
//                      dataStream: extDataStream,
//                      style: widget.candlesticksStyle,
//                    )
//                ),
            Positioned.fill(
              child: Visibility(
                visible: true,
                child: AABBWidget(
                  extDataStream: extDataStream,
                  durationMs: durationMs,
                  rangeX: rangeX,
                  candlesticksStyle: widget.candlesticksStyle,
                  paddingY: widget.candlesticksStyle.maStyle.cameraPaddingY,
                  child: GraticuleNetWidget(
                    paddingY: 0.1,
                    candlesticksStyle: widget.candlesticksStyle,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Visibility(
                visible: defaultIndicatorSwitch.rsiSwitch,
                maintainState: true,
                child: AABBWidget(
                  extDataStream: extDataStream,
                  durationMs: durationMs,
                  rangeX: rangeX,
                  candlesticksStyle: widget.candlesticksStyle,
                  paddingY: widget.candlesticksStyle.maStyle.cameraPaddingY,
                  child: RsiWidget(
                    dataStream: extDataStream,
                    style: widget.candlesticksStyle,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Visibility(
                visible: defaultIndicatorSwitch.wrSwitch,
                maintainState: true,
                child: AABBWidget(
                  extDataStream: extDataStream,
                  durationMs: durationMs,
                  rangeX: rangeX,
                  candlesticksStyle: widget.candlesticksStyle,
                  paddingY: widget.candlesticksStyle.maStyle.cameraPaddingY,
                  child: WrWidget(
                    dataStream: extDataStream,
                    style: widget.candlesticksStyle,
                  ),
                ),
              ),
            ),
          ],
        )
    );
//    return AABBWidget(
//        extDataStream: extDataStream,
//        durationMs: durationMs,
//        rangeX: rangeX,
//        candlesticksStyle: widget.candlesticksStyle,
//        paddingY: widget.candlesticksStyle.maStyle.cameraPaddingY,
//        child: Container(
//            decoration: BoxDecoration(
//              color: widget.candlesticksStyle.backgroundColor,
//            ),
//            child: Stack(
//              children: <Widget>[
////                Positioned.fill(
////                    top: 12,
////                    child: CandlesWidget(
////                      dataStream: extDataStream,
////                      style: widget.candlesticksStyle,
////                    )
////                ),
//                Positioned.fill(
//                  child: Visibility(
//                    visible: defaultIndicatorSwitch.rsiSwitch,
//                    maintainState: true,
//                    child: RsiWidget(
//                      dataStream: extDataStream,
//                      style: widget.candlesticksStyle,
//                    ),
//                  ),
//                ),
//                Positioned.fill(
//                  child: Visibility(
//                    visible: defaultIndicatorSwitch.wrSwitch,
//                    maintainState: true,
//                    child: WrWidget(
//                      dataStream: extDataStream,
//                      style: widget.candlesticksStyle,
//                    ),
//                  ),
//                ),
//              ],
//            )
//        )
//    );
  }
}
