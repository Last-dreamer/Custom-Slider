import 'package:flutter/material.dart';
import 'package:wave_slider/waveSlider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Wave Slider',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(32.0),
            child: const Center(child: WaveSlider()),
          ),
        ));
  }
}
