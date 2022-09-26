import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wave_slider/waveSlider.dart';

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;
  final double animationProgress;

  final WaveState sliderState;

  final Color color;

  final Paint wavePainter;
  final Paint fillPainter;

  double _previousSliderPosition = 0.0;

  WavePainter({
    required this.sliderPosition,
    required this.dragPercentage,
    required this.animationProgress,
    required this.sliderState,
    required this.color,
  })  : wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
        fillPainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);

    switch (sliderState) {
      case WaveState.starting:
        _paintStartupWave(canvas, size);
        break;
      case WaveState.resting:
        _paintRestingWave(canvas, size);
        break;
      case WaveState.sliding:
        _paintSlidingWave(canvas, size);
        break;
      case WaveState.stopping:
        _paintStoppingWave(canvas, size);
        break;
      default:
        _paintSlidingWave(canvas, size);
        break;
    }
  }

  _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, size.height), 5.0, fillPainter);
    canvas.drawCircle(Offset(size.width, size.height), 5.0, fillPainter);
  }

  _paintRestingWave(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  _paintStartupWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);

    double? waveHeight = lerpDouble(size.height, line.controlHeight,
        Curves.elasticOut.transform(animationProgress));
    line.controlHeight = waveHeight!;
    _paintWaveLine(canvas, size, line);
  }

  _paintSlidingWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);
    _paintWaveLine(canvas, size, line);
  }

  _paintStoppingWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);

    double? waveHeight = lerpDouble(line.controlHeight, size.height,
        Curves.elasticOut.transform(animationProgress));

    line.controlHeight = waveHeight!;

    _paintWaveLine(canvas, size, line);
  }

  _paintWaveLine(Canvas canvas, Size size, WaveCurveDefinitions waveCurve) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(waveCurve.startOfBezier, size.height);
    path.cubicTo(
        waveCurve.leftControlPoint1,
        size.height,
        waveCurve.leftControlPoint2,
        waveCurve.controlHeight,
        waveCurve.centerPoint,
        waveCurve.controlHeight);
    path.cubicTo(
        waveCurve.rightControlPoint1,
        waveCurve.controlHeight,
        waveCurve.rightControlPoint2,
        size.height,
        waveCurve.endOfBezier,
        size.height);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, wavePainter);
  }

  WaveCurveDefinitions _calculateWaveLineDefinitions(Size size) {
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
  double startOfBezier;
  double endOfBezier;
  double leftControlPoint1;
  double leftControlPoint2;
  double rightControlPoint1;
  double rightControlPoint2;
  double controlHeight;
  double centerPoint;

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
