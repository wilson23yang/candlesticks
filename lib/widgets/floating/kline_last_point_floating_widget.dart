import 'package:candlesticks/utils/canvas_util.dart';
import 'package:candlesticks/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

///
class TopFloatingPainter extends CustomPainter {
  final AnimationCandleData lastCandleData;
  final UICamera uiCamera;
  final CandlesticksStyle style;
  final double durationMs;
  final bool showPoint;
  final bool showLabel;
  final double opacity;
  final double pointRadius;
  final int precision;

  Paint lastPointPainter;
  Paint lastLabelTextPainter;
  Paint lastBorderPainter;
  Paint lastBorderBgPainter;
  Paint dashLinePainter;
  Paint trianglePainter;

  TopFloatingPainter({
    this.uiCamera,
    this.style,
    this.durationMs,
    this.lastCandleData,
    this.showLabel,
    this.showPoint,
    this.opacity,
    this.pointRadius,
    this.precision,
  });

  TextPainter calLabel(Canvas canvas, Size size, String text) {
    TextPainter leftTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: style.klineFloatingStyle.textColor,
            fontSize: style.klineFloatingStyle.textSize,
          ),
        ));
    leftTextPainter.layout();
    return leftTextPainter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (lastCandleData == null || uiCamera == null) {
      return;
    }
    var touchWorldPoint = UIOPoint(
        lastCandleData.timeMs + lastCandleData.durationMs ,
        lastCandleData.close);
    var touchScenePoint = uiCamera.viewPortToScreenPoint(
        size, uiCamera.worldToViewPortPoint(touchWorldPoint));
    var realPoint = Offset(touchScenePoint.dx, touchScenePoint.dy);

    if (showLabel) {
      if (lastLabelTextPainter == null) {
        lastLabelTextPainter = Paint();
        lastLabelTextPainter.color = style.klineFloatingStyle.textColor;
        lastLabelTextPainter.style = PaintingStyle.stroke;
      }
      if (lastBorderPainter == null) {
        lastBorderPainter = Paint();
        lastBorderPainter.color = style.klineFloatingStyle.lineColor;
        lastBorderPainter.strokeWidth = 1.2;
        lastBorderPainter.style = PaintingStyle.stroke;
      }
      if (lastBorderBgPainter == null) {
        lastBorderBgPainter = Paint();
        lastBorderBgPainter.color = style.klineFloatingStyle.textBgColor;
        lastBorderBgPainter.style = PaintingStyle.fill;
      }
      if (dashLinePainter == null) {
        dashLinePainter = Paint();
        dashLinePainter.strokeWidth = style.mhStyle.dashLineWidth;
        dashLinePainter.color = style.klineFloatingStyle.lineColor;
        dashLinePainter.style = PaintingStyle.stroke;
      }
      if (trianglePainter == null) {
        trianglePainter = Paint();
        trianglePainter.strokeWidth = style.mhStyle.dashLineWidth;
        trianglePainter.color = style.klineFloatingStyle.lineColor;
        trianglePainter.style = PaintingStyle.fill;
      }
      var labelText = calLabel(canvas, size, StringUtil.formatAssetNum(
          lastCandleData.close.toString(), precision));

      double textWidth = labelText.width;
      double textHeight = labelText.height;
      double lGap = 5;
      double rGap = 8;
      double aGap = 8;
      double vGap = 5;

      if (size.width - realPoint.dx - textWidth < 10) {
        //显示在左边
        double dashLen = 70;

        double rightPointXMax = realPoint.dx;
        double rightPointYMax = realPoint.dy;
        if (rightPointXMax > size.width) {
          rightPointXMax = size.width;
        }
        if (rightPointYMax > size.height) {
          rightPointYMax = size.height - textWidth / 2 - vGap;
        }
        if (rightPointYMax < 0) {
          rightPointYMax = textWidth / 2 + vGap;
        }
        Offset originPoint = Offset(
            rightPointXMax - dashLen - lGap - textWidth - rGap - aGap,
            rightPointYMax - textHeight / 2.0 - vGap);


        Offset p1 = Offset(size.width, rightPointYMax);
        Offset p2 = Offset(rightPointXMax - dashLen + rGap, rightPointYMax);
        CanvasUtil.drawDash(
            canvas, size, dashLinePainter, p1, p2, style.mhStyle.dashLineGap);

        Offset p3 = Offset(0, rightPointYMax);
        Offset p4 = Offset(originPoint.dx - lGap, rightPointYMax);
        CanvasUtil.drawDash(
            canvas, size, dashLinePainter, p3, p4, style.mhStyle.dashLineGap);

        RRect rrect = RRect.fromLTRBR(originPoint.dx - lGap,
            rightPointYMax - labelText.height / 2.0 - vGap,
            rightPointXMax - dashLen + rGap,
            rightPointYMax + labelText.height / 2.0 + vGap,
            Radius.circular(50.0));
        canvas.drawRRect(rrect, lastBorderBgPainter);
        canvas.drawRRect(rrect, lastBorderPainter);

        Path path = Path();
        path.moveTo(rightPointXMax - dashLen - rGap, rightPointYMax - labelText.height / 2.0);
        path.lineTo(rightPointXMax - dashLen, rightPointYMax);
        path.lineTo(rightPointXMax - dashLen - rGap, rightPointYMax + labelText.height / 2.0);
        path.close();
        canvas.drawPath(path, trianglePainter);

        labelText.paint(
            canvas,
            Offset(rightPointXMax - dashLen - textWidth - rGap - aGap,
                rightPointYMax - textHeight / 2.0));

      } else {
        //显示在右边
        double rightPointXMax = size.width - 2;
        double rightPointYMax = realPoint.dy;
        if (rightPointYMax > size.height) {
          rightPointYMax = size.height - textWidth / 2 - vGap;
        }
        if (rightPointYMax < 0) {
          rightPointYMax = textWidth / 2 + vGap;
        }
        Offset originPoint = Offset(rightPointXMax, rightPointYMax - textHeight / 2.0 - vGap);
        labelText.paint(
            canvas,
            Offset(rightPointXMax - textWidth,
                rightPointYMax - textHeight / 2.0));

        Offset p1 = Offset((originPoint.dx - 10 - textWidth), rightPointYMax);
        Offset p2 = Offset(realPoint.dx, rightPointYMax);
        CanvasUtil.drawDash(
            canvas, size, dashLinePainter, p1, p2, style.mhStyle.dashLineGap);
      }
    }
  }

  @override
  bool shouldRepaint(TopFloatingPainter oldPainter) {
    return /*this?.lastCandleData?.durationMs !=
        oldPainter?.lastCandleData?.durationMs ||
        this?.lastCandleData?.close != oldPainter?.lastCandleData?.close ||
        this?.opacity != oldPainter?.opacity ||
        this?.pointRadius != oldPainter?.pointRadius*/true;
  }

  @override
  bool shouldRebuildSemantics(TopFloatingPainter oldDelegate) {
    return false;
  }
}

///
class KLineLastPointFloatingWidget extends StatefulWidget {
  KLineLastPointFloatingWidget({
    Key key,
    this.style,
    this.durationMs,
    this.lastCandleData,
    this.showPoint = true,
    this.showLabel = true,
  }) : super(key: key);

  final CandlesticksStyle style;
  final double durationMs;
  final ExtCandleData lastCandleData;
  final bool showPoint;
  final bool showLabel;

  @override
  _LastPointFloatingWidgetState createState() =>
      _LastPointFloatingWidgetState();
}

///
class _LastPointFloatingWidgetState extends State<KLineLastPointFloatingWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _candleDataController;
  Animation<double> opacityAnimation;
  Animation<double> radiusAnimation;
  Animation<AnimationCandleData> _candleDataAnimation;
  AnimationCandleData _beginCandleData;

  @override
  void initState() {
    super.initState();
    _candleDataController = AnimationController( //
      vsync: this, //
      duration: const Duration(milliseconds: 300),
    );

    _controller = AnimationController(
      vsync: this, //
      duration: const Duration(milliseconds: 1000),
    );
    opacityAnimation = Tween(begin: 0.5, end: 0.9).animate(_controller);
    radiusAnimation = Tween(begin: 1.5, end: 1.5).animate(_controller);
    opacityAnimation.addListener(() {
      setState(() {});
    });
    radiusAnimation.addListener(() {
      setState(() {});
    });
    _controller.addStatusListener((AnimationStatus s) {
      if (s == AnimationStatus.completed) {
        _controller.reverse();
      } else if (s == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _candleDataController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lastCandleData == null) {
      return Container();
    }
    var uiCamera = AABBContext
        .of(context)
        .uiCamera;

    _beginCandleData = addCandleDataAnimation(
      begin: _beginCandleData,
      end: AnimationCandleData.from(widget.lastCandleData),
    );
    return CustomPaint(
      painter: TopFloatingPainter(
        style: widget.style,
        uiCamera: uiCamera,
        lastCandleData: _candleDataAnimation?.value ??
            AnimationCandleData.from(widget.lastCandleData),
        durationMs: widget.durationMs,
        showLabel: widget.showLabel,
        showPoint: widget.showPoint,
        opacity: opacityAnimation?.value ?? 1.0,
        pointRadius: radiusAnimation?.value ?? 2.0,
        precision: StringUtil.getPrecision(widget.lastCandleData.close),
      ),
    );
  }

  AnimationCandleData addCandleDataAnimation(
      {AnimationCandleData begin, AnimationCandleData end,}) {
    if (begin == null) {
      _candleDataAnimation = null;
      begin = end;
    }
    if (begin.close == end.close) {
      return end;
    }
    _candleDataAnimation = null;
    _candleDataController.reset();
    Tween<AnimationCandleData> tween = Tween(begin: begin, end: end);
    _candleDataAnimation = tween.animate(_candleDataController);
    _candleDataAnimation.addListener(() {
      try {
        if (mounted) {
          setState(() {});
        }
      } catch (_) {}
    });
    _candleDataController.forward();
    return end;
  }

}


///
class AnimationCandleData {
  final int timeMs;
  final double open;
  final double close;
  final double high;
  final double low;
  final double volume;
  final double durationMs;

  AnimationCandleData({
    this.timeMs,
    this.open,
    this.close,
    this.high,
    this.low,
    this.volume,
    this.durationMs,
  });

  AnimationCandleData.from(final ExtCandleData item)
      : timeMs = item.timeMs,
        open = item.open,
        high = item.high,
        low = item.low,
        close = item.close,
        volume = item.volume,
        durationMs = item.durationMs;

  AnimationCandleData operator -(AnimationCandleData other) {
    if (other == null) {
      return this;
    }

    return AnimationCandleData(
      timeMs: this.timeMs - other.timeMs,
      durationMs: this.durationMs,
      open: this.open - other.open,
      close: this.close - other.close,
      high: this.high - other.high,
      low: this.low - other.low,
      volume: this.volume - other.volume,
    );
  }

  AnimationCandleData operator +(AnimationCandleData other) {
    if (other == null) {
      return this;
    }
    return AnimationCandleData(
      timeMs: this.timeMs + other.timeMs,
      durationMs: this.durationMs,
      open: this.open + other.open,
      close: this.close + other.close,
      high: this.high + other.high,
      low: this.low + other.low,
      volume: this.volume + other.volume,
    );
  }

  AnimationCandleData operator *(double progress) {
    return AnimationCandleData(
      timeMs: (this.timeMs * progress).toInt(),
      durationMs: this.durationMs,
      open: this.open * progress,
      close: this.close * progress,
      high: this.high * progress,
      low: this.low * progress,
      volume: this.volume * progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AnimationCandleData &&
              runtimeType == other.runtimeType &&
              timeMs == other.timeMs &&
              open == other.open &&
              close == other.close &&
              high == other.high &&
              low == other.low &&
              volume == other.volume &&
              durationMs == other.durationMs;

  @override
  int get hashCode =>
      timeMs.hashCode ^
      open.hashCode ^
      close.hashCode ^
      high.hashCode ^
      low.hashCode ^
      volume.hashCode ^
      durationMs.hashCode;

}


