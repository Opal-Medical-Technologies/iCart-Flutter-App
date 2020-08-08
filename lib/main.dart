import 'package:flutter/material.dart';
import 'UI/weightScreen.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WeightScreen();
  }
}