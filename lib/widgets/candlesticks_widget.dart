import 'package:candlesticks/widgets/line_type.dart';
import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/candlesticks_view.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class CandlesticksWidget extends StatefulWidget {

    CandlesticksWidget({
        Key key,
        this.dataStream,
        this.candlesticksStyle,
        this.durationMs,
        this.lineType = LineType.k_line,
    }) :super(key: key);

    final double durationMs;
    final Stream<CandleData> dataStream;
    final CandlesticksStyle candlesticksStyle;
    final LineType lineType;

    @override
    CandlesticksView createState() => CandlesticksView(dataStream:dataStream);
}

