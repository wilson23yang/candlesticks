import 'package:candlesticks/widgets/mh/mh_context.dart';
import 'package:candlesticks/widgets/mh/mh_value_data.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/ui_animated_widget.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/ma/ma_value_widget.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';


class MHPriceView extends UIAnimatedView<UIOPath, UIOPoint> {

  Paint painter;
  Color color;
  double width;

  MHContext mhContext;

  MHPriceView(this.color,this.width) : super(animationCount: 2) {
    painter = new Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

  }


  @override
  UIOPoint getCandle(ExtCandleData candleData) {

    print('ExtCandleData    ${candleData.close}    ${candleData.index}');
    return UIOPoint(candleData.timeMs.toDouble() + candleData.durationMs.toDouble()/2.0, candleData.close,index: candleData.index);
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

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    mhContext = MHContext.of(context);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
  }
}

class MHPriceWidgetState extends State<MHPriceWidget> {

  AABBContext candlesticksContext;

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    candlesticksContext = AABBContext.of(context);
  }

  MHValueData mhValueData;

  onMHChange(double price, int timeMs) {
    if (mhValueData == null) {
      mhValueData = MHValueData();
    }
    mhValueData = MHValueData(price: price,timeMs: timeMs);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    var uiCamera = candlesticksContext?.uiCamera;
    return MHContext(
        onMHChange: onMHChange,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: UIAnimatedWidget<UIOPath, UIOPoint>(
                  dataStream: widget.dataStream,
                  uiCamera: uiCamera,
                  duration: const Duration(seconds: 0),
                  state: () =>
                      MHPriceView(widget.style.mhStyle.lineColor,widget.style.mhStyle.lineWidth),
                )
            ),
          ],
        ));
  }
}


class MHPriceWidget extends StatefulWidget {
  MHPriceWidget({
    Key key,
    this.dataStream,
    this.style,
    this.maType,
  }) : super(key: key);

  final Stream<ExtCandleData> dataStream;
  final CandlesticksStyle style;
  final MaType maType;

  @override
  MHPriceWidgetState createState() => MHPriceWidgetState();
}
