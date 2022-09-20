import 'dart:ui';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;
  final Color color;
  final Paint fillPainter;
  final Paint wavePainter;
  double _previousSliderValue = 0.0;

  WavePainter(
      {required this.sliderPosition,
      required this.dragPercentage,
      required this.color})
      : fillPainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);
    // _paintLine(canvas, size);
    // _paintBlock(canvas, size);
    _paintWaveLine(canvas, size);
  }

  WaveCurveDefinitions _calWaveLineDif(Size size) {
    double minWaveHeight = size.height * 0.2;
    double maxWaveHeight = size.height * 0.8;
    double controlHeight =
        (size.height - minWaveHeight) - (maxWaveHeight * dragPercentage);
    double bendWidth = 20 + 20 * dragPercentage;
    double bezierWidth = 20 + 20 * dragPercentage;

    double centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;

    double startOfBend = sliderPosition - bendWidth / 2;
    double startOfBezeir = startOfBend - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezeir = endOfBend + bezierWidth;

    startOfBend = (startOfBend <= 0.0) ? 0.0 : startOfBend;
    startOfBezeir = (startOfBezeir <= 0.0) ? 0.0 : startOfBezeir;
    endOfBend = (endOfBend >= size.width) ? size.width : endOfBend;
    endOfBezeir = (endOfBezeir >= size.width) ? size.width : endOfBezeir;

    double leftControllerPoint1 = startOfBend;
    double leftControllerPoint2 = startOfBend;
    double rightControllerPoint1 = endOfBend;
    double rightControllerPoint2 = endOfBend;

    double bendability = 5.0;
    double maxSliderDifference = 30.0;
    double sliderDifference = (sliderPosition - maxSliderDifference).abs();

    if (sliderDifference > maxSliderDifference) {
      sliderDifference = maxSliderDifference;
    }

    bool moveLeft = sliderPosition < _previousSliderValue;
    double? bend =
        lerpDouble(0.0, bendability, sliderDifference / maxSliderDifference);

    bend = moveLeft ? -bend! : bend;

    leftControllerPoint1 = leftControllerPoint1 + bend!;
    leftControllerPoint2 = leftControllerPoint2 - bend;
    rightControllerPoint1 = rightControllerPoint1 - bend;
    rightControllerPoint2 = rightControllerPoint2 + bend;
    centerPoint = centerPoint - bend;

    WaveCurveDefinitions waveCurveDefinitions = WaveCurveDefinitions(
        startOfBezier: startOfBezeir,
        endOfBezier: endOfBezeir,
        leftControlPoint1: leftControllerPoint1,
        leftControlPoint2: leftControllerPoint2,
        rightControlPoint1: rightControllerPoint1,
        rightControlPoint2: rightControllerPoint2,
        controlHeight: controlHeight,
        centerPoint: centerPoint);
    return waveCurveDefinitions;
  }

  _paintWaveLine(Canvas canvas, Size size) {
    WaveCurveDefinitions waveDif = _calWaveLineDif(size);
    Path path = Path();

    path.moveTo(0.0, size.height);
    path.lineTo(waveDif.startOfBezier, size.height);

    path.cubicTo(
        waveDif.leftControlPoint1,
        size.height,
        waveDif.leftControlPoint2,
        waveDif.controlHeight,
        waveDif.centerPoint,
        waveDif.controlHeight);
    path.cubicTo(
        waveDif.rightControlPoint1,
        waveDif.controlHeight,
        waveDif.rightControlPoint2,
        size.height,
        waveDif.endOfBezier,
        size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0, size.height), 5.0, fillPainter);
    canvas.drawCircle(Offset(size.width, size.height), 5.0, fillPainter);
  }

  _paintLine(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  _paintBlock(Canvas canvas, Size size) {
    Rect rect =
        Offset(sliderPosition, size.height - 5.0) & const Size(10.0, 10.0);
    canvas.drawRect(rect, fillPainter);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    _previousSliderValue = oldDelegate.sliderPosition;
    return true;
  }
}

class WaveCurveDefinitions {
  final double startOfBezier;
  final double endOfBezier;
  final double leftControlPoint1;
  final double leftControlPoint2;
  final double rightControlPoint1;
  final double rightControlPoint2;
  final double controlHeight;
  final double centerPoint;

  WaveCurveDefinitions({
    required this.startOfBezier,
    required this.endOfBezier,
    required this.leftControlPoint1,
    required this.leftControlPoint2,
    required this.rightControlPoint1,
    required this.rightControlPoint2,
    required this.controlHeight,
    required this.centerPoint,
  });
}
