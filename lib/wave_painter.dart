import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wave_slider/waveSlider.dart';

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;
  final double animationProgress;
  final WaveState sliderState;
  final Color color;
  final Paint fillPainter;
  final Paint wavePainter;

  double _previousSliderPosition = 0.0;

  WavePainter(
      {required this.sliderPosition,
      required this.dragPercentage,
      required this.animationProgress,
      required this.sliderState,
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
    switch (sliderState) {
      case WaveState.starting:
        _paintingStartupWave(canvas, size);
        break;
      case WaveState.resting:
        _paintingRestingWave(canvas, size);
        break;
      case WaveState.sliding:
        _paintingSlidingWave(canvas, size);
        break;
      case WaveState.stopping:
        _paintingStoppingWave(canvas, size);
        break;
      default:
        _paintingSlidingWave(canvas, size);
        break;
    }
  }

  _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0, size.height), 5.0, fillPainter);
    canvas.drawCircle(Offset(size.width, size.height), 5.0, fillPainter);
  }

  _paintingRestingWave(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  _paintingStartupWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calWaveLineDif(size);

    double? waveHeight = lerpDouble(size.height, line.controlHeight,
        Curves.elasticOut.transform(animationProgress));
    line.controlHeight = waveHeight!;
    _paintWaveLine(canvas, size, line);
  }

  _paintingSlidingWave(Canvas canvas, Size size) {
    WaveCurveDefinitions waveDif = _calWaveLineDif(size);
    _paintWaveLine(canvas, size, waveDif);
  }

  _paintingStoppingWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calWaveLineDif(size);
    double? waveHeight = lerpDouble(line.controlHeight, size.height,
        Curves.elasticOut.transform(animationProgress));

    line.controlHeight = waveHeight!;
    _paintWaveLine(canvas, size, line);
  }

  _paintWaveLine(Canvas canvas, Size size, WaveCurveDefinitions waveDif) {
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

  WaveCurveDefinitions _calWaveLineDif(Size size) {
    double minWaveHeight = size.height * 0.2;
    double maxWaveHeight = size.height * 0.8;

    double controlHeight =
        (size.height - minWaveHeight) - (maxWaveHeight * dragPercentage);

    double bendWidth = 20 + 20 * dragPercentage;
    double bezierWidth = 20 + 20 * dragPercentage;

    double centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;

    double startOfBend = centerPoint - bendWidth / 2;
    double startOfBezier = startOfBend - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezier = endOfBend + bezierWidth;

    startOfBend = (startOfBend <= 0.0) ? 0.0 : startOfBend;
    startOfBezier = (startOfBezier <= 0.0) ? 0.0 : startOfBezier;
    endOfBend = (endOfBend > size.width) ? size.width : endOfBend;
    endOfBezier = (endOfBezier > size.width) ? size.width : endOfBezier;

    double leftBendControlPoint1 = startOfBend;
    double leftBendControlPoint2 = startOfBend;
    double rightBendControlPoint1 = endOfBend;
    double rightBendControlPoint2 = endOfBend;

    double bendability = 25.0;
    double maxSlideDifference = 30.0;
    double slideDifference = (sliderPosition - _previousSliderPosition).abs();

    slideDifference = (slideDifference > maxSlideDifference)
        ? maxSlideDifference
        : slideDifference;

    double? bend =
        lerpDouble(0.0, bendability, slideDifference / maxSlideDifference);
    bool moveLeft = sliderPosition < _previousSliderPosition;
    bend = moveLeft ? -bend! : bend;

    leftBendControlPoint1 = leftBendControlPoint1 + bend!;
    leftBendControlPoint2 = leftBendControlPoint2 - bend;
    rightBendControlPoint1 = rightBendControlPoint1 - bend;
    rightBendControlPoint2 = rightBendControlPoint2 + bend;

    centerPoint = centerPoint - bend;

    WaveCurveDefinitions waveCurveDefinitions = WaveCurveDefinitions(
      controlHeight: controlHeight,
      startOfBezier: startOfBezier,
      endOfBezier: endOfBezier,
      leftControlPoint1: leftBendControlPoint1,
      leftControlPoint2: leftBendControlPoint2,
      rightControlPoint1: rightBendControlPoint1,
      rightControlPoint2: rightBendControlPoint2,
      centerPoint: centerPoint,
    );

    return waveCurveDefinitions;
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    double diff = _previousSliderPosition - oldDelegate.sliderPosition;
    if (diff.abs() > 20) {
      _previousSliderPosition = sliderPosition;
    } else {
      _previousSliderPosition = oldDelegate.sliderPosition;
    }
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
  double controlHeight;
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
