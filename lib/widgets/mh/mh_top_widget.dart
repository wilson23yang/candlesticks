import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/widgets/boll/boll_view.dart';
import 'package:candlesticks/widgets/floating/last_point_floating_widget.dart';
import 'package:candlesticks/widgets/indicator_switch.dart';
import 'package:candlesticks/widgets/ma/ma_value_widget.dart';
import 'package:candlesticks/widgets/mh/mh_price_view.dart';
import 'package:flutter/material.dart';

import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_widget.dart';
import 'package:candlesticks/widgets/graticule/graticule_widget.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/floating/floating_widget.dart';

class MHTopWidget extends StatelessWidget {

  MHTopWidget({
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
    var candlesticksContext = CandlesticksContext.of(context);

    return AABBWidget(
        extDataStream: extDataStream,
        durationMs: durationMs,
        rangeX: rangeX,
        candlesticksStyle: widget.candlesticksStyle,
        paddingY: widget.candlesticksStyle.candlesStyle.cameraPaddingY,
        child: Container(
            decoration: BoxDecoration(
              color: widget.candlesticksStyle.backgroundColor,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: MHPriceWidget(
                    dataStream: widget.extDataStream,
                    style: widget.candlesticksStyle,
                    maType: MaType.price,
                  ),
                ),
                Positioned.fill(
                  child: FloatingWidget(
                    style: candlesticksStyle,
                    extCandleData: candlesticksContext.extCandleData,
                    touchPoint: candlesticksContext.touchPoint,
                    durationMs: widget.durationMs,
                  ),
                ),
                Positioned.fill(
                  child: LastPointFloatingWidget(
                    style: candlesticksStyle,
                    durationMs: widget.durationMs,
                    lastCandleData: candlesticksContext.lastCandleData,
                  ),
                ),
                Positioned.fill(
                  child: GraticuleWidget(
                    candlesticksStyle: this.candlesticksStyle,
                    paddingY: 0.1,
                  ),
                ),
              ],
            )
        ));
  }
}

