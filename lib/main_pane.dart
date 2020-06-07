import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

/*
TODO:
3) compile and debug and make it look nice
*/

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

  String conc_str; //constant to divide from dosage (mg/ml or mcg/ml)
  double conc_val;
  String conc_unit; //same unit as first unit in conc_str
  int currDose = 0; //index of current dosage corresponding to dosages list
  bool administered = false; // true if has been administered before

  List<double> first_dosages; //list of dosages for buttons for first dose (mg/kg or mcg/kg)
  List<double> seq_dosages; //list of dosages for buttons for subsequent dose (mg/kg or mcg/kg)

  double first_min;
  double first_max;
  double seq_min;
  double seq_max;

  Medcard(this.name, this.notes, this.type, this.conc_str, this.first_dosages, this.seq_dosages, this.first_min, this.first_max, this.seq_min, this.seq_max) {
    double numerator;
    double denominator;

    var originalString = conc_str;
    var string = originalString.split("/");

    String numer_str = string[0];
    String denom_str = string[1];

    for (int i = 0; i < numer_str.length; ++i) {
      if (!isDigit(numer_str[i])) {
        this.conc_unit = this.type == CardType.medication ? numer_str.substring(i) : numer_str.substring(i) + "/hour";
        numerator = double.parse(numer_str.substring(0, i));
        break;
      }
    }

    for (int i = 0; i < denom_str.length; ++i) {
      if (!isDigit(numer_str[i])) {
        if (i == 0) {
          denominator =1;
        }
        else {
          numerator = double.parse(numer_str.substring(0, i));
        }
        break;
      }
    }

    this.conc_val = numerator / denominator;

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
  int wt;
  int state = 0; //driptable vs medications


  Set<TimeLineEntry> entries = Set<TimeLineEntry>();
  ListView timeline;
  List<Container> driptable = [];
  List<Container> medications = [];
  List<Medcard> cards;

  _MainPaneState(this.wt) {
    Medcard card1 = Medcard("Test1", "Test1 notes", CardType.medication, "3mg/ml", [0.2, 0.4, 0.6, 0.8, 1.0, 1.2], [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 2, 8, 2, 8);
    Medcard card2 = Medcard("Test2", "Test2 notes", CardType.drip, "3mg/ml", [0.2, 0.4, 0.6, 0.8, 1.0, 1.2], [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 2, 8, 2, 8);
    cards.add(card1);
    cards.add(card2);
  }


  Container toButton(double dose, Medcard mc) {//converts double value to a dosage button
    List<double> dosages = mc.administered ? mc.seq_dosages : mc.first_dosages;
    
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
    return Column(
      children: [
          Text(
            "${mc.name}",
            style: TextStyle(fontSize: 30)
          ),
          Text(
            "${mc.conc_str}",
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
    List<double> dosageList = mc.administered ? mc.seq_dosages : mc.first_dosages;
    double administerAmount = mc.type == CardType.medication ? dosageList[mc.currDose] * widget.wt : dosageList[mc.currDose] * widget.wt * 60;

    double administerButtonAmount = administerAmount * mc.conc_val;

    if (mc.administered) {
      if (mc.seq_max != -1 && administerButtonAmount > mc.seq_max) {
        administerButtonAmount = mc.seq_max;
      }
      else if (mc.seq_min != -1 && administerButtonAmount < mc.seq_min) {
        administerButtonAmount = mc.seq_min;
      }
    }
    else {
      if (mc.first_max != -1 && administerButtonAmount > mc.first_max) {
        administerButtonAmount = mc.first_max;
      }
      else if (mc.first_min != -1 && administerButtonAmount < mc.first_min) {
        administerButtonAmount = mc.first_min;
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
                  TimeLineEntry add = TimeLineEntry("${mc.name}", DateTime.now(), "${administerAmount.toStringAsFixed(1)} ${mc.conc_unit}");
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
    List<double> dosageList = mc.administered ? mc.seq_dosages : mc.first_dosages;
    String doseText = mc.type == CardType.medication ? mc.conc_unit + "/kg" : mc.conc_unit + "/kg/min";

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
    for (int i = 0; i < cards.length; ++i) {
      if (cards[i].type == CardType.medication) {
        medications.add(gencard(cards[i]));
      }
      else {
        driptable.add(gencard(cards[i]));
      }
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
                        child: Text(
                        "${DateFormat('kk:mm:ss').format(DateTime.now())}",
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