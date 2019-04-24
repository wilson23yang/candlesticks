import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:flutter/material.dart';

class BollWidget extends StatefulWidget {

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;

  BollWidget({
    Key key,
    this.dataStream,
    this.style,
  }) : super(key: key);

  @override
  _BollWidgetState createState() => _BollWidgetState();
}

class _BollWidgetState extends State<BollWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
