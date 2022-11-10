import 'package:flutter/material.dart';
import 'package:sns_speed_test/widget/speed_test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test',
      home: SpeedTestWidget(),
    );
  }
}
