import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CardType {
  medication,
  drip
}

class Medcard {
  String name;
  String notes;
  CardType type;//medication or driptable

  double concentration; //constant to divide from dosage (mg/ml or mcg/ml)
  String concentration_units;
  String dosage_units;
  int currDose = 0; //index of current dosage corresponding to dosages list
  bool administered = false; // true if has been administered before

  List<double> first_dosages; //list of dosages for buttons for first dose (mg/kg or mcg/kg)
  List<double> seq_dosages; //list of dosages for buttons for subsequent dose (mg/kg or mcg/kg)

  double first_min;
  double first_max;
  double seq_min;
  double seq_max;

  Medcard(this.name, this.notes, this.type, this.concentration_units, this.dosage_units, this.first_dosages, this.seq_dosages, this.first_min, this.first_max, this.seq_min, this.seq_max);
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

  _MainPaneState(this.wt);


  Container toButton(double dose, Medcard mc) {//converts double value to a dosage button
    List<double> dosages;
    if (mc.administered) {
      dosages = mc.first_dosages;
    }
    else {
      dosages = mc.seq_dosages;
    }
    
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

  Container gencard(Medcard mc) {//converts Medcard to actual card interface
    if (mc.type == CardType.drip) { //belongs in drip table
      Widget titleBlock = Text(
        "${mc.name}",
        style: TextStyle(fontSize: 30)
      );
      Widget notes = Text(
        "${mc.notes}",
        style: TextStyle(fontSize: 20)
      );

      Widget doseButton = Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text("RATE (ml/hour)"),
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
                    TimeLineEntry add = TimeLineEntry("${mc.name}", DateTime.now(), "${mc.dosages[mc.currDose].toStringAsFixed(1)} ${mc.unit}");
                    entries.add(add);
                  });
                },
                child: Center(
                  child: Text(
                    "${(mc.dosages[mc.currDose] * widget.wt * 60 / mc.amount).toStringAsFixed(1)}",
                    style: TextStyle(fontSize: 30)
                  )
                )
              )
            )
          ],
        ),
      );
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 3,
          ),
          borderRadius: (BorderRadius.all(Radius.circular(20)))
        ),
        child: Column(
          children: [
            titleBlock,
            notes,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Column(
                    children: [
                      Text("DOSE (mcg/kg/min)"),
                      Row(
                        children: [
                          toButton(mc.dosages[0], mc),
                          toButton(mc.dosages[1], mc),
                          toButton(mc.dosages[2], mc),
                        ]
                      ),
                      Row(
                        children: [
                          toButton(mc.dosages[3], mc),
                          toButton(mc.dosages[4], mc),
                          toButton(mc.dosages[5], mc),
                        ]
                      ),
                    ]
                  )
                ),
                doseButton,
              ]
            )
          ]
        )
      );
    }
    else {//belongs in medication table
      Widget titleBlock = Text("${mc.name}",
        style: TextStyle(fontSize: 30));
      Widget notes = Text(
        "${mc.notes}",
        style: TextStyle(fontSize: 18)
      );
      List<Container> buttons = [];
      for (int i = 0; i < mc.dosages.length; ++i) {
        buttons.add(toButton(mc.dosages[i], mc));
      }
      Widget doseButton = Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text("RATE (ml/hour)"),
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
                    TimeLineEntry add = TimeLineEntry("${mc.name}", DateTime.now(), "${mc.dosages[mc.currDose].toStringAsFixed(1)} ${mc.unit}");
                    entries.add(add);
                  });
                },
                child: Center(
                  child: Text(
                    "${(mc.dosages[mc.currDose] * widget.wt / mc.amount).toStringAsFixed(1)}",
                    style: TextStyle(fontSize: 30)
                  )
                )
              )
            )
          ],
        ),
      );
      return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 3),
          borderRadius: BorderRadius.all(
            Radius.circular(20)
          )
        ),
        child: Column(
          children: [
            titleBlock,
            notes,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      Text("Dose (${mc.unit}/kg)"),
                      Row(
                        children:buttons
                      )
                    ]
                  )
                ),
                doseButton
              ]
            )
          ]
        )
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    /*for (int i = 0; i < cards.length; ++i) {
      if (cards[i].type == CardType.drip) {
        driptable.add(gencard(cards[i]));
      }
      else {
        medications.add(gencard(cards[i]));
      }
    }*/
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