import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_state.dart';
import 'package:candlesticks/widgets/candles/candles_widget.dart';
import 'package:candlesticks/widgets/ma/ma_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_context_widget.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';

class AABBView extends AABBState {
  AABBView() : super();


  @override
  Widget build(BuildContext context) {
    var uiCamera;
    if (widget.rangeX != null) {
      uiCamera = calUICamera(widget.rangeX.minX, widget.rangeX.maxX);
    }
    return AABBContext(
        onAABBChange: onAABBChange,
        uiCamera: uiCamera,
        durationMs: widget.durationMs,
        child:widget.child,
        extDataStream: exdataStream,
    );
  }
}
