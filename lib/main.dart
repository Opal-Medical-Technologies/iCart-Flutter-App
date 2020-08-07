import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'weight_screen.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WeightScreen();
  }
}

