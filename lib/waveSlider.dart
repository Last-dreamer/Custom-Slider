import 'package:flutter/material.dart';
import 'package:wave_slider/wave_painter.dart';

class WaveSlider extends StatefulWidget {
  final double width;
  final double height;

  const WaveSlider({
    Key? key,
    this.width = 350.0,
    this.height = 50,
  }) : super(key: key);

  @override
  State<WaveSlider> createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider> {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  void _updateDragPosition(Offset val) {
    double newDragPosition = 0;

    if (val.dx <= 0) {
      newDragPosition = 0;
    } else if (val.dx >= widget.width) {
      newDragPosition = widget.width;
    } else {
      newDragPosition = val.dx;
    }

    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = newDragPosition / widget.width;
    });
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails details) {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset offset = box.globalToLocal(details.globalPosition);
    _updateDragPosition(offset);
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset offset = box.globalToLocal(start.globalPosition);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: (DragUpdateDetails details) =>
            _onDragUpdate(context, details),
        onHorizontalDragStart: (DragStartDetails details) =>
            _onDragStart(context, details),
        onHorizontalDragEnd: (DragEndDetails details) =>
            _onDragEnd(context, details),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: WavePainter(
                color: Colors.black,
                dragPercentage: _dragPercentage,
                sliderPosition: _dragPosition),
          ),
        ));
  }
}
