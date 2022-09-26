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

class _WaveSliderState extends State<WaveSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  WaveSliderController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaveSliderController(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
    _controller?.setStateToSliding();
    _updateDragPosition(offset);
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset offset = box.globalToLocal(start.globalPosition);
    _controller?.setStateToStart();
    _updateDragPosition(offset);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    _controller?.setStateToStopping();
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
            painter:
                // ?  tt calss
                // WavePainter(
                //   animationProgress: _controller!.progress,
                //   color: Colors.black,
                //   dragPercentage: _dragPercentage,
                //   sliderPosition: _dragPosition,
                //   sliderState: _controller!.state),
                /// ? normal wave
                WavePainter(
              animationProgress: _controller!.progress,
              sliderState: _controller!.state,
              color: Colors.black,
              dragPercentage: _dragPercentage,
              sliderPosition: _dragPosition,
            ),
          ),
        ));
  }
}

class WaveSliderController extends ChangeNotifier {
  final AnimationController controller;
  WaveState _state = WaveState.resting;

  WaveSliderController({required TickerProvider vsync})
      : controller = AnimationController(vsync: vsync) {
    controller
      ..addListener(_onProgessUpdate)
      ..addStatusListener(_onStatusUpdate);
  }

  double get progress => controller.value;
  WaveState get state => _state;

  _onProgessUpdate() {
    notifyListeners();
  }

  _onStatusUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onTransitionCompleted();
    }
  }

  _onTransitionCompleted() {
    if (_state == WaveState.stopping) {
      setStateToResting();
    }
  }

  void _startAnimation() {
    controller.duration = const Duration(milliseconds: 500);
    controller.forward(from: 0.0);
    notifyListeners();
  }

  setStateToResting() {
    _state = WaveState.resting;
    notifyListeners();
  }

  setStateToStart() {
    _startAnimation();
    _state = WaveState.starting;
  }

  setStateToStopping() {
    _startAnimation();
    _state = WaveState.stopping;
  }

  setStateToSliding() {
    _state = WaveState.sliding;
  }
}

enum WaveState { starting, resting, sliding, stopping }
