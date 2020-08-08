import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main_pane.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}

class WeightScreen extends StatefulWidget {
  @override
  _WeightScreenState createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  bool next;
  int weight;
  Text weightText = Text("Please select a weight",
      style: TextStyle(fontSize: 40, fontFamily: 'SelawikSemibold'));

  List<Widget> weightButtons = [];

  _WeightScreenState() {
    weightButtons.add(weightButton(3, -1));
    weightButtons.add(weightButton(4, -1));
    weightButtons.add(weightButton(5, -1));
    weightButtons.add(weightButton(6, 7));
    weightButtons.add(weightButton(8, 9));
    weightButtons.add(weightButton(10, 11));
    weightButtons.add(weightButton(12, 14));
    weightButtons.add(weightButton(15, 18));
    weightButtons.add(weightButton(19, 23));
    weightButtons.add(weightButton(24, 29));
    weightButtons.add(weightButton(30, 36));
    weightButtons.add(weightButton(37, -1));
    next = false;
  }

  Container weightButton(int weight1, int weight2) {
    if (weight2 == -1) {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40.0))),
          height: 120,
          width: 150,
          padding: EdgeInsets.all(10),
          child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  weightText = Text("Weight: $weight1 kg",
                      style: TextStyle(fontSize: 40, fontFamily: 'Selawik'));
                  weight = weight1;
                  next = true;
                });
              },
              child: Text(
                "$weight1 kg",
                style: TextStyle(fontSize: 20.0, fontFamily: 'Selawik'),
              )));
    } else {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40.0))),
          height: 120,
          width: 150,
          padding: EdgeInsets.all(10),
          child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  weightText = Text("Weight: ${(weight1 + weight2) ~/ 2} kg",
                      style: TextStyle(fontSize: 40, fontFamily: 'Selawik'));
                  weight = (weight1 + weight2) ~/ 2;
                  next = true;
                });
              },
              child: Text(
                "$weight1-$weight2 kg",
                style: TextStyle(fontSize: 20.0, fontFamily: 'Selawik'),
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Container(
                child: Stack(children: [
      Positioned(
          top: 15.0,
          right: 15.0,
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: FlatButton(
                  color: next ? Colors.blue : Colors.grey,
                  textColor: Colors.white,
                  onPressed: next
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainPane(wt: weight)),
                          );
                        }
                      : null,
                  child: Text("Next",
                      style: TextStyle(fontSize: 40, fontFamily: 'Selawik'))))),
      Column(children: [
        Container(
          padding: EdgeInsets.all(20),
          child: weightText,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    weightButtons[0],
                    weightButtons[1],
                    weightButtons[2],
                    weightButtons[3],
                  ])),
          Container(
              padding: EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    weightButtons[4],
                    weightButtons[5],
                    weightButtons[6],
                    weightButtons[7],
                  ])),
          Container(
              padding: EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    weightButtons[8],
                    weightButtons[9],
                    weightButtons[10],
                    weightButtons[11],
                  ])),
        ])
      ])
    ]))));
  }
}
