import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'dart:convert';


//SUPER DUMB, change later
bool complete = false;

enum CardType {
  medication,
  drip
}

bool isDigit(String s) {
  return s == "0"
      || s == "1"
      || s == "2"
      || s == "3"
      || s == "4"
      || s == "5"
      || s == "6"
      || s == "7"
      || s == "8"
      || s == "9";
}

class Medcard {
  String name;
  String notes;
  CardType type;//medication or driptable

  String concStr; //constant to divide from dosage (mg/ml or mcg/ml)
  double concVal;
  String concUnit; //same unit as first unit in concStr
  int currDose = 0; //index of current dosage corresponding to dosages list
  bool administered = false; // true if has been administered before

  List<double> firstDosages; //list of dosages for buttons for first dose (mg/kg or mcg/kg)
  List<double> seqDosages; //list of dosages for buttons for subsequent dose (mg/kg or mcg/kg)

  double firstMin;
  double firstMax;
  double seqMin;
  double seqMax;

  Medcard(this.name, this.notes, this.type, this.concStr, this.firstDosages, this.seqDosages, this.firstMin, this.firstMax, this.seqMin, this.seqMax) {
    double numerator;
    double denominator;

    var originalString = concStr;
    var string = originalString.split("/");

    String numerStr = string[0];
    print(numerStr);
    String denomStr = string[1];
    print(denomStr);
    for (int i = 0; i < numerStr.length; ++i) {
      if (!isDigit(numerStr[i])) {
        this.concUnit = this.type == CardType.medication ? numerStr.substring(i) : numerStr.substring(i) + "/hour";
        numerator = double.parse(numerStr.substring(0, i));
        break;
      }
    }

    for (int i = 0; i < denomStr.length; ++i) {
      if (!isDigit(denomStr[i])) {
        
        if (i == 0) {
          denominator = 1;
        }
        else {
          denominator = double.parse(denomStr.substring(0, i));
        }
        break;
      }
    }

    this.concVal = numerator / denominator;

  }
}

class TimeLineEntry {
  String medication;
  DateTime time;
  String dosage;

  TimeLineEntry(String m, DateTime t, String d) {
    medication = m;
    time = t;
    dosage = d;
  }
}


class MainPane extends StatefulWidget {
  final int wt;

  MainPane({Key key, @required this.wt}) : super(key: key);

  @override
  _MainPaneState createState() => _MainPaneState(wt);
}

class _MainPaneState extends State<MainPane> {
  // TIME UPDATE STUFF
  String _timeString;

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('kk:mm:ss').format(dateTime);
  }
  
  int wt;
  int state = 0; //driptable vs medications


  Set<TimeLineEntry> entries = Set<TimeLineEntry>();
  ListView timeline;
  List<Container> driptable = [];
  List<Container> medications = [];
  List<Medcard> cards = new List();

  _MainPaneState(this.wt) {

    /* Medcard(this.name, this.notes, this.type, this.concStr, this.firstDosages, 
    this.seqDosages, this.firstMin, this.firstMax, this.seqMin, this.seqMax) */

    // OLD
    Medcard card1 = Medcard("Test1", "Test1 notes", CardType.medication, "3mg/ml", [0.2, 0.4, 0.6, 0.8, 1.0, 1.2], [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 2, 8, 2, 8);
    Medcard card2 = Medcard("Test2", "Test2 notes", CardType.drip, "4.0mg/2ml", [0.2, 0.4, 0.6, 0.8, 1.0, 1.2], [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 2, 8, 2, 8);
    Medcard card3 = Medcard("Test3", "Test1 notes", CardType.medication, "5mg/ml", [0.3, 0.1, 0.6, 0.8, 1.0, 1.2], [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 2, 8, 2, 8);
  
    cards.add(card1);
    cards.add(card2);
    cards.add(card3);
  }


  Container toButton(double dose, Medcard mc) {//converts double value to a dosage button
    List<double> dosages = mc.administered ? mc.seqDosages : mc.firstDosages;
    
    return Container(
      padding: EdgeInsets.all(5),
      width: 80,
      height: 45,
      child: RaisedButton(
        child: Text("$dose", style: TextStyle(fontSize: 20)),
        color: dosages[mc.currDose] == dose ? Colors.blue: Colors.white,
        textColor: dosages[mc.currDose] == dose ? Colors.white : Colors.grey,
        onPressed: () {
          setState(() {
            mc.currDose = dosages.indexOf(dose);
          });
        },
      )
    );
  }


  Widget titleBlock(Medcard mc) {
    return

    //VERY JANKY
              Column(
                // Orients this left within column
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Text(
                          "   ${mc.name}",
                          style: TextStyle(fontSize: 30)
                        ),
                   Text(
                        "   ${mc.concStr}",
                        style: TextStyle(fontSize: 20)
                      ),
                ]
              );
  }

  Widget notesBlock(Medcard mc) {
    return Column(
      children: [
        Text("Notes", style: TextStyle(fontSize: 30)),
        Text("${mc.notes}", style: TextStyle(fontSize: 20))
      ]
    );
  }

  Widget administerButton(Medcard mc) {
    String uppertext = mc.type == CardType.medication ? "RATE (mL/hour)" : "RATE (mL)";
    List<double> dosageList = mc.administered ? mc.seqDosages : mc.firstDosages;
    double administerAmount = mc.type == CardType.medication ? dosageList[mc.currDose] * widget.wt : dosageList[mc.currDose] * widget.wt * 60;

    double administerButtonAmount = administerAmount * mc.concVal;

    if (mc.administered) {
      if (mc.seqMax != -1 && administerButtonAmount > mc.seqMax) {
        administerButtonAmount = mc.seqMax;
      }
      else if (mc.seqMin != -1 && administerButtonAmount < mc.seqMin) {
        administerButtonAmount = mc.seqMin;
      }
    }
    else {
      if (mc.firstMax != -1 && administerButtonAmount > mc.firstMax) {
        administerButtonAmount = mc.firstMax;
      }
      else if (mc.firstMin != -1 && administerButtonAmount < mc.firstMin) {
        administerButtonAmount = mc.firstMin;
      }
    }
    
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(uppertext),
          Container(
            height: 130,
            width: 130,
            decoration: BoxDecoration(
              border: Border.all()
            ),
            child: RaisedButton(
              color: Colors.white,
              onPressed: () {
                setState(() {
                  TimeLineEntry add = TimeLineEntry("${mc.name}", DateTime.now(), "${administerAmount.toStringAsFixed(1)} ${mc.concUnit}");
                  entries.add(add);
                  mc.administered = true;
                });
              },
              child: Center(
                child: Text(
                  "${administerButtonAmount.toStringAsFixed(1)}",
                  style: TextStyle(fontSize: 30)
                )
              )
            )
          )
        ],
      ),
    );
  }

  Widget dosageSelection(Medcard mc) {
    List<double> dosageList = mc.administered ? mc.seqDosages : mc.firstDosages;
    String doseText = mc.type == CardType.medication ? mc.concUnit + "/kg" : mc.concUnit + "/kg/min";

    if (dosageList.length == 1) {
      return Container(
        child: Text(dosageList[0].toStringAsFixed(1) + " " + doseText)
      );
    }
    else {
      return Container(
        child: Column(
          children: [
            Text("DOSE (" + doseText + ")"),
            Row(
              children: new List<Widget>.generate(3, (int index) => toButton(dosageList[index], mc))
            ),
            Row(
              children: new List<Widget>.generate(dosageList.length - 3, (int index) => toButton(dosageList[index + 3], mc))
            ),
          ]
        )
      );
    }
  }


  Container gencard(Medcard mc) {//converts Medcard to actual card interface
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 3,
          ),
          borderRadius: (BorderRadius.all(Radius.circular(20)))
        ),
        child: Column(
          // TEST LINE AXIS ALIGNMENT
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBlock(mc),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    dosageSelection(mc),
                    notesBlock(mc)
                  ]
                ),
                administerButton(mc)
              ]
            )
          ]
        )
      );
  }



  @override
  Widget build(BuildContext context) {
    if (!complete) {
      for (int i = 0; i < cards.length; ++i) {
        if (cards[i].type == CardType.medication) {
          medications.add(gencard(cards[i]));
        }
        else {
          driptable.add(gencard(cards[i]));
        }
      }
      complete = true;
    }
    //driptable hard code:
    GridView medGV = GridView.count(
      childAspectRatio: 1.9,
      crossAxisCount: 2,
      children:medications
    );

    GridView dripGV = GridView.count(
      childAspectRatio:1.9,
      crossAxisCount: 2,
      children:driptable
    );

    //TimeLine code
    final Iterable<Container> tiles = (entries.toList().reversed).map(
      (TimeLineEntry entry) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(20)
            )
          ),
          child:ListTile(
          title: Text('${entry.medication}',
          style: TextStyle(fontSize: 20)),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              Container(
                padding:EdgeInsets.all(5),
                child:Text('${DateFormat('kk:mm:ss').format(entry.time)}',
                style: TextStyle(fontSize: 16))),
              Container(
                padding:EdgeInsets.all(5),
                child:Text('${entry.dosage}',
                style: TextStyle(fontSize: 16))),
            ]
          ),
          trailing: IconButton(
            icon: Icon(Icons.close),
            tooltip: 'Remove Timeline Entry',
            onPressed: () {
              setState(() {
                entries.remove(entry);
              });
            }
          )
        ));
      }
    );
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    timeline = ListView(children: divided);


    return MaterialApp(
      home: Scaffold(
        body:Container(
          constraints: BoxConstraints.expand(
            height:MediaQuery.of(context).size.height,
            width:MediaQuery.of(context).size.width,
          ),
          child:Stack(
            children: [
              Container(
              alignment: Alignment.topLeft,
              constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height*0.925,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  right: BorderSide(
                    color: Colors.black,
                    width: 2.5,
                  )
                )
              ),
              child: Column(
                children:[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height*0.1,
                    child: Center(
                      child:Text(
                      "Timeline",
                      style: TextStyle(fontSize: 35),
                    ))
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height*0.825,
                    child: Center(
                      child: timeline,
                    )
                  )
                ]
              )
            ),
            Positioned(
              right:0,
              top:MediaQuery.of(context).size.height*0.1,
              child:Container(
                width:MediaQuery.of(context).size.width*0.8,
                height: MediaQuery.of(context).size.height*0.825,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  left: BorderSide(
                    color: Colors.black,
                    width: 2.5,
                  )
                )
              ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                      Container(
                        width:MediaQuery.of(context).size.width*0.7,
                        height: MediaQuery.of(context).size.height*0.825,
                        child:state == 1 ? medGV : dripGV
                        ),
                        Container(
                          padding: EdgeInsets.all(20)
                        ),
                    Container(
                      child:Column(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children:[
                        Container(
                          child:RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              child:FlatButton(
                              color: (state == 1) ? Colors.blue : Colors.white,
                              textColor: (state == 1) ? Colors.white : Colors.black,
                              child: Text("          Medications          ",
                              style: TextStyle(fontSize: 25, fontFamily: 'Roboto')),
                              onPressed: () {
                                setState(() {
                                  state = 1;
                                });
                              }
                            )

                          ))
                        ),
                        Container(
                          child:RotatedBox(
                            quarterTurns: 3,
                            child: FlatButton(
                              color: (state == 0) ? Colors.blue : Colors.white,
                              textColor: (state == 0) ? Colors.white : Colors.black,
                              child: Text("          Drip Tables          ",
                              style: TextStyle(fontSize: 25)),
                              onPressed: () {
                                setState(() {
                                  state = 0;
                                });
                              }
                            )

                          )
                        )
                      ]
                    ))
                  ]
                )
              )
            ),
            Positioned(
              top:0,
              right:0,
              child:Container(
                width:MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height*0.1,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    left: BorderSide(
                      color: Colors.black,
                      width: 2.5,
                    ),
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 5
                    )
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width*0.1,
                      height : MediaQuery.of(context).size.height,
                      child: Center(
                        child: Text(
                          "${widget.wt} kg",
                          style: TextStyle(fontSize: 35)
                        )
                      )
                    )
                  ]
                )
              )
            ),
            Positioned(
              bottom:0,
              child:Container(
                width:MediaQuery.of(context).size.width,
                height:MediaQuery.of(context).size.height*0.075,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(
                      color: Colors.black,
                      width: 5
                    )
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    Container(
                      width: MediaQuery.of(context).size.width*0.2,
                      height : MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.black,
                            width: 2.5
                          )
                        )
                      ),
                      child: Center(
                        child: Text(_timeString,
                        //"${DateFormat('kk:mm:ss').format(DateTime.now())}",
                        style: TextStyle(fontSize: 30),
                      ))
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.3,
                      height : MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.black,
                            width: 2.5,
                          ),
                          right: BorderSide(
                            color: Colors.black,
                            width: 2.5,
                          )
                        )
                      ),
                      child: Center(
                        child:Text(
                        "Defibrillation (2 J/kg): ${widget.wt * 2} J",
                        style: TextStyle(fontSize: 30),
                      ))
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.5,
                      height : MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.black,
                            width: 2.5
                          )
                        )
                      ),
                      child: Center(
                        child:Text(
                        "Cardioversion (Synchronized) (0.5 J/kg): ${widget.wt / 2} J",
                        style: TextStyle(fontSize: 30),
                      ))
                    ),
                  ]
                )
              )
            )
          ])
        )
      )
    );
  }
}