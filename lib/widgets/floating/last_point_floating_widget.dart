import 'package:candlesticks/utils/canvas_util.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/2d/candle_data.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class TopFloatingPainter extends CustomPainter {
  final ExtCandleData lastCandleData;
  final UICamera uiCamera;
  final CandlesticksStyle style;
  final double durationMs;
  final bool showPoint;
  final bool showLabel;
  final Animation opacityAnimation;
  final Animation sizeAnimation;

  Paint lastPointPainter;
  Paint lastLabelTextPainter;
  Paint lastBorderPainter;
  Paint lastBorderBgPainter;
  Paint dashLinePainter;

  TopFloatingPainter({
    this.uiCamera,
    this.style,
    this.durationMs,
    this.lastCandleData,
    this.showLabel,
    this.showPoint,
    this.opacityAnimation,
    this.sizeAnimation,
  });

  TextPainter calLabel(Canvas canvas, Size size, String text) {
    TextPainter leftTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: style.mhStyle.labelColor,
            fontSize: style.mhStyle.textSize,
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
        lastCandleData.timeMs + lastCandleData.durationMs / 2,
        lastCandleData.close);
    var touchScenePoint = uiCamera.viewPortToScreenPoint(
        size, uiCamera.worldToViewPortPoint(touchWorldPoint));
    var realPoint = Offset(touchScenePoint.dx, touchScenePoint.dy);

    if (showLabel) {
      if (lastLabelTextPainter == null) {
        lastLabelTextPainter = Paint();
        lastLabelTextPainter.color = style.mhStyle.labelColor;
        lastLabelTextPainter.style = PaintingStyle.stroke;
      }
      if (lastBorderPainter == null) {
        lastBorderPainter = Paint();
        lastBorderPainter.color = style.mhStyle.labelBorderColor;
        lastBorderPainter.strokeWidth = 1.2;
        lastBorderPainter.style = PaintingStyle.stroke;
      }
      if (lastBorderBgPainter == null) {
        lastBorderBgPainter = Paint();
        lastBorderBgPainter.color = style.mhStyle.labelBgColor;
        lastBorderBgPainter.style = PaintingStyle.fill;
      }
      if (dashLinePainter == null) {
        dashLinePainter = Paint();
        dashLinePainter.strokeWidth = style.mhStyle.dashLineWidth;
        dashLinePainter.color = style.mhStyle.dashLineColor;
        dashLinePainter.style = PaintingStyle.stroke;
      }

      var labelText = calLabel(canvas, size, lastCandleData.close.toString());

      double textWidth = labelText.width;
      double textHeight = labelText.height;
      double lGap = 4;
      double rGap = 4;
      double aGap = 8;
      double vGap = 3;

      if (realPoint.dx > size.width * 4.0 / 5.0) {
        //显示在右边
        //print('显示在右边');
        double dashLen = 100;

        Path path = Path();
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
        path.moveTo(originPoint.dx, originPoint.dy);
        path.lineTo(originPoint.dx + lGap + textWidth + rGap, originPoint.dy);
        path.lineTo(originPoint.dx + lGap + textWidth + rGap + aGap,
            originPoint.dy + textHeight / 2.0 + vGap);
        path.lineTo(originPoint.dx + lGap + textWidth + rGap,
            originPoint.dy + textHeight + 2 * vGap);
        path.lineTo(originPoint.dx, originPoint.dy + textHeight + 2 * vGap);
        path.close();
        canvas.drawPath(path, lastBorderPainter);
        canvas.drawPath(path, lastBorderBgPainter);

        labelText.paint(
            canvas,
            Offset(rightPointXMax - dashLen - textWidth - rGap - aGap,
                rightPointYMax - textHeight / 2.0));

        Offset p1 = Offset(size.width, rightPointYMax);
        Offset p2 = Offset(rightPointXMax - dashLen, rightPointYMax);
        CanvasUtil.drawDash(
            canvas, size, dashLinePainter, p1, p2, style.mhStyle.dashLineGap);

        Offset p3 = Offset(0, rightPointYMax);
        Offset p4 = Offset(originPoint.dx, rightPointYMax);
        CanvasUtil.drawDash(
            canvas, size, dashLinePainter, p3, p4, style.mhStyle.dashLineGap);
      } else {
        //显示在左边
        //print('显示在左边');

        Path path = Path();
        double rightPointXMax = size.width - 2;
        double rightPointYMax = realPoint.dy;
        if (rightPointYMax > size.height) {
          rightPointYMax = size.height - textWidth / 2 - vGap;
        }
        if (rightPointYMax < 0) {
          rightPointYMax = textWidth / 2 + vGap;
        }
        Offset originPoint =
            Offset(rightPointXMax, rightPointYMax - textHeight / 2.0 - vGap);
        path.moveTo(originPoint.dx, originPoint.dy);
        path.lineTo(originPoint.dx - lGap - textWidth - rGap, originPoint.dy);
        path.lineTo(originPoint.dx - lGap - textWidth - rGap - aGap,
            originPoint.dy + textHeight / 2.0 + vGap);
        path.lineTo(originPoint.dx - lGap - textWidth - rGap,
            originPoint.dy + textHeight + 2 * vGap);
        path.lineTo(originPoint.dx, originPoint.dy + textHeight + 2 * vGap);
        path.close();
        canvas.drawPath(path, lastBorderPainter);
        canvas.drawPath(path, lastBorderBgPainter);

        labelText.paint(
            canvas,
            Offset(rightPointXMax - textWidth - rGap,
                rightPointYMax - textHeight / 2.0));

        Offset p1 = Offset(
            (originPoint.dx - lGap - textWidth - rGap - aGap), rightPointYMax);
        Offset p2 = Offset(realPoint.dx, rightPointYMax);
        CanvasUtil.drawDash(
            canvas, size, dashLinePainter, p1, p2, style.mhStyle.dashLineGap);
      }
    }

    if (showPoint) {
      if (lastPointPainter == null) {
        lastPointPainter = Paint();
        lastPointPainter.color =
            style.mhStyle.pointColor.withOpacity(opacityAnimation.value);
        lastPointPainter.style = PaintingStyle.fill;
      }
      canvas.drawCircle(realPoint,
          style.mhStyle.pointRadius + sizeAnimation.value, lastPointPainter);
    }
  }

  @override
  bool shouldRepaint(TopFloatingPainter oldPainter) {
    return this?.lastCandleData?.durationMs !=
            oldPainter?.lastCandleData?.durationMs ||
        this?.lastCandleData?.close != oldPainter?.lastCandleData?.close;
  }

  @override
  bool shouldRebuildSemantics(TopFloatingPainter oldDelegate) {
    return false;
  }
}

class LastPointFloatingWidget extends StatefulWidget {
  LastPointFloatingWidget({
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

class _LastPointFloatingWidgetState extends State<LastPointFloatingWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation opacityAnimation;
  Animation sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    CurvedAnimation ca = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
    opacityAnimation = Tween(begin: 0.8, end: 1.0).animate(ca);
    sizeAnimation = Tween(begin: 0.0, end: 1.5).animate(ca);
    opacityAnimation.addListener(() {
      if (opacityAnimation.value == 1.0) {
        _controller.reverse();
      } else if (opacityAnimation.value == 0.8) {
        _controller.forward();
      }
    });
    sizeAnimation.addListener(() {
      if (sizeAnimation.value == 1.5) {
        _controller.reverse();
      } else if (sizeAnimation.value == 0.0) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lastCandleData == null) {
      return Container();
    }
    var uiCamera = AABBContext.of(context).uiCamera;
    return CustomPaint(
      painter: TopFloatingPainter(
        style: widget.style,
        uiCamera: uiCamera,
        lastCandleData: widget.lastCandleData,
        durationMs: widget.durationMs,
        showLabel: widget.showLabel,
        showPoint: widget.showPoint,
        opacityAnimation: opacityAnimation,
        sizeAnimation: sizeAnimation,
      ),
    );
  }
}
