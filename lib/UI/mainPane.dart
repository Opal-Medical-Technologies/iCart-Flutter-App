import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flip_card/flip_card.dart';

import 'dart:async';
import 'dart:core';

import '../utils/utils.dart';
import '../utils/testData.dart';
import '../dataStructures/medCard.dart';
import '../dataStructures/timelineEntry.dart';

final medKey = new GlobalKey();
final dripKey = new GlobalKey();
//GlobalKey<FlipCardState> flipKey = new GlobalKey<FlipCardState>();

class MainPane extends StatefulWidget {
  final int wt;
  MainPane({Key key, @required this.wt}) : super(key: key);

  @override
  _MainPaneState createState() => _MainPaneState(wt);
}

class _MainPaneState extends State<MainPane> {
  SliverGrid medGV, dripGV;
  String _timeString = currentTime();
  int state = 0; //driptable vs medications
  Set<TimeLineEntry> entries = Set<TimeLineEntry>();
  List<Medcard> cards;

  int wt;

  _MainPaneState(this.wt) {
    cards = TEST_CARD_LIST;
  }

/*
* Functions for building medcard components
* Components Include:
*  Title Block
*  Notes Block
*  Administer Button
*  Dosage Selection Button
*/

  //converts double value to dosage selection button
  Container toButton(double dose, Medcard mc) {
    List<double> dosages = mc.administered ? mc.seqDosages : mc.firstDosages;
    return Container(
      padding: EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * .0625,
      height: MediaQuery.of(context).size.height * .05331754,
      child: FlatButton(
        child: Text("$dose", style: TextStyle(fontSize: 13.6, fontFamily: 'Selawik')),
        color: (dosages[mc.currDose] == dose) ? Colors.teal : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), 
          side: BorderSide(color: Colors.teal)),
        textColor: (dosages[mc.currDose] == dose) ? Colors.white : Colors.teal,
        onPressed: () {
          setState(() {
            mc.currDose = dosages.indexOf(dose);
          });
        },
      )
    );
  }

  //creates the title text for a medCard
  Widget titleBlock(Medcard mc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [  
        Text(
          "${mc.name}",
          style: TextStyle(fontSize: 30, fontFamily: 'SelawikSemiBold', color: Colors.black)),
        mc.type == CardType.medication ? 
        Text(
          "${mc.concStr}",
          style: TextStyle(fontSize: 22, fontFamily: 'Selawik', color: Colors.black)) : 
        Text(
          "${mc.concStr}",
          style: TextStyle(fontSize: 18, fontFamily: 'Selawik', color: Colors.black))
      ]
    );
  }

  //creates the notes text for a medcard
  Widget notesBlock(Medcard mc) {
    if (mc.notes != "" || mc.type == CardType.medication) {
      List<double> dosageList =
          mc.administered ? mc.seqDosages : mc.firstDosages;
      String doseText = mc.type == CardType.medication
          ? mc.concUnit + "/kg"
          : mc.concUnit + "/kg/min";
      return Container(
          //height : 160,
          child: Align(
              alignment: Alignment.topCenter,
              child: Column(children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      mc.type == CardType.medication && mc.notes != ""
                          ? Text("NOTES",
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'SelawikSemiBold'))
                          : Container(),
                    ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  dosageList.length == 1
                      ? Text(
                          dosageList[0].toStringAsFixed(2) + " " + doseText,
                          style: TextStyle(fontSize: 24, fontFamily: 'Selawik'),
                        )
                      : Container(),
                  Container(
                      width: MediaQuery.of(context).size.width * .1953125,
                      child: mc.type == CardType.medication
                          ? Text(
                              "${mc.notes}",
                              style: TextStyle(fontSize: 16),
                            )
                          : Text(
                              " ${mc.notes}",
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'Selawik'),
                            ))
                ])
              ])));
    } else {
      return Column();
    }
  }

  //creates the administer button
  Widget administerButton(Medcard mc) {
    String uppertext = mc.type == CardType.drip ? "RATE (mL/hour)" : "RATE (mL)";
    List<double> dosageList = mc.administered ? mc.seqDosages : mc.firstDosages;
    double administerAmount = mc.type == CardType.medication
        ? dosageList[mc.currDose] * widget.wt
        : dosageList[mc.currDose] * widget.wt * 60;

    double administerButtonAmount = administerAmount / mc.concVal;

    if (mc.administered) {
      if (mc.seqMax != -1 && administerButtonAmount > mc.seqMax) {
        administerButtonAmount = mc.seqMax;
      } else if (mc.seqMin != -1 && administerButtonAmount < mc.seqMin) {
        administerButtonAmount = mc.seqMin;
      }
    } else {
      if (mc.firstMax != -1 && administerButtonAmount > mc.firstMax) {
        administerButtonAmount = mc.firstMax;
      } else if (mc.firstMin != -1 && administerButtonAmount < mc.firstMin) {
        administerButtonAmount = mc.firstMin;
      }
    }

    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Text(uppertext,
              style: TextStyle(fontSize: 16, fontFamily: 'SelawikSemiBold')),
          Container(
              height: MediaQuery.of(context).size.height * .12,
              width: MediaQuery.of(context).size.width * .1015625,
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      TimeLineEntry add = TimeLineEntry(
                          "${mc.name}",
                          DateTime.now(),
                          "${administerAmount.toStringAsFixed(1)} ${mc.concUnit}");
                      entries.add(add);
                      mc.administered = true;
                    });
                  },
                  child: Center(
                      child: Text(
                          "${administerButtonAmount.toStringAsFixed(1)}",
                          style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'SelawikSemiBold',
                              color: Colors.black)))))
        ],
      ),
    );
  }

  //creates the array of buttons for selecting dosages
  Widget dosageSelection(Medcard mc) {
    List<double> dosageList = mc.administered ? mc.seqDosages : mc.firstDosages;
    String doseText = mc.type == CardType.medication
        ? mc.concUnit + "/kg"
        : mc.concUnit + "/kg/min";
    if (dosageList.length == 1) {
      return Container(
          );
    } else {
      return Container(
          width: MediaQuery.of(context).size.width * .1953125,
          child: Column(children: [
            Text("DOSE (" + doseText + ")",
                style: TextStyle(fontFamily: 'SelawikSemiBold', fontSize: 15)),
            Wrap(
                children: new List<Widget>.generate(dosageList.length,
                    (int index) => toButton(dosageList[index], mc))),
          ]));
    }
  }

/*
* Converts a single medcard data structure into an actual medcard UI.
* Calls above medcard component functions.
* Returns flipcard corresponding to a single medcard.
*/
  Widget genCard(Medcard mc) {
    return FlipCard(
        direction: FlipDirection.HORIZONTAL,
        //key: flipKey,
        //flipOnTouch: false,
        front: Container(
            child: Stack(children: <Widget>[
          Container(),
          Container(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * .01,
                MediaQuery.of(context).size.width * .005,
                MediaQuery.of(context).size.width * .01,
                MediaQuery.of(context).size.width * .002,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[500],
                      spreadRadius: 0,
                      blurRadius: 0,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  border: Border.all(
                    width: MediaQuery.of(context).size.width * .001,
                    color: Colors.grey[500],
                  ),
                  borderRadius: (BorderRadius.all(Radius.circular(20)))),
              child: Column(
                  // TEST LINE AXIS ALIGNMENT
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* Container(
                  height: MediaQuery.of(context).size.height * 0.01,
                  decoration: BoxDecoration(color: Colors.teal)), */

                    titleBlock(mc),
                    Container(
                        height: MediaQuery.of(context).size.height * .15668246,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        .0035),
                                child: Column(children: [
                                  dosageSelection(mc),
                                  notesBlock(mc)
                                ]),
                              ),
                              administerButton(mc)
                            ]))
                  ])),
          Container(
              child: Positioned(
            top: 0,
            child: Container(
              color: Colors.teal,
            ),
          )),
        ])),
        back: Container(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * .01,
            MediaQuery.of(context).size.width * .005,
            MediaQuery.of(context).size.width * .01,
            MediaQuery.of(context).size.width * .002,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[500],
                  spreadRadius: 0,
                  blurRadius: 0,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              border: Border.all(
                width: MediaQuery.of(context).size.width * .001,
                color: Colors.grey[500],
              ),
              borderRadius: (BorderRadius.all(Radius.circular(20)))),
        ));
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (Timer t) => setState(() {
          _timeString = currentTime();
        }));
    super.initState();
  }

  void populateSliverGrids() {
    List<FlipCard> driptable = [];
    List<FlipCard> medications = [];

    for (int i = 0; i < cards.length; ++i) {
      if (cards[i].type == CardType.medication) {
        medications.add(genCard(cards[i]));
      } else {
        driptable.add(genCard(cards[i]));
      }
    }

    medGV = SliverGrid.count(
        childAspectRatio: 1.9,
        crossAxisCount: 2,
        crossAxisSpacing: MediaQuery.of(context).size.height * .0118,
        mainAxisSpacing: MediaQuery.of(context).size.width * .0078,
        children: medications);

    dripGV = SliverGrid.count(
        childAspectRatio: 1.9,
        crossAxisCount: 2,
        crossAxisSpacing: MediaQuery.of(context).size.height * .0118,
        mainAxisSpacing: MediaQuery.of(context).size.width * .0078,
        children: driptable);
  } 

  ListView generateTimeline() {
    final Iterable<Container> tiles =
        (entries.toList().reversed).map((TimeLineEntry entry) {
      return Container(
          decoration: BoxDecoration(
              border: Border.all(
                width: MediaQuery.of(context).size.width * .00078125,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: ListTile(
              title: Text('${entry.medication}',
                  style: TextStyle(fontSize: 20, fontFamily: 'Selawik')),
              subtitle:
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    padding: EdgeInsets.all(5),
                    child: Text('${DateFormat('kk:mm:ss').format(entry.time)}',
                        style: TextStyle(fontSize: 16, fontFamily: 'Selawik'))),
                Container(
                    padding: EdgeInsets.all(5),
                    child: Text('${entry.dosage}',
                        style: TextStyle(fontSize: 16, fontFamily: 'Selawik'))),
              ]),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  tooltip: 'Remove Timeline Entry',
                  onPressed: () {
                    setState(() {
                      entries.remove(entry);
                    });
                  })));
    });
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return ListView(children: divided);
  }

  Container timelineTab(ListView timeline) {
    return Container(
        alignment: Alignment.topLeft,
        constraints: BoxConstraints.expand(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height * 0.94,
        ),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
                right: BorderSide(
              color: Colors.black,
              width: 5,
            ))),
        // */
        child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.025),
          Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Text("${widget.wt} kg",
                      style: TextStyle(
                        fontFamily: 'SelawikSemiBold',
                        fontSize: 60,
                      )))),
          Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.05,
              child: Center(
                  child: Text(
                "TIMELINE",
                style: TextStyle(
                    fontSize: 30, fontFamily: 'SelawikSemiLight'),
              ))),
          Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.72,
              child: Center(
                child: timeline,
              ))
        ]));
  }

  Container drugList() {
    return Container(
        width: MediaQuery.of(context).size.width *
            0.77,
        height: MediaQuery.of(context).size.height *
            0.94,
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.02,
          0,
          MediaQuery.of(context).size.height * 0.02,
          0,
        ),
        child: CustomScrollView(
          controller: new ScrollController(),
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
                child: Container(
                    height: MediaQuery.of(context)
                            .size
                            .height *
                        0.025)),
            SliverToBoxAdapter(
                child: Container(
              height: MediaQuery.of(context)
                      .size
                      .height *
                  0.05,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("MEDICATIONS ", //janky
                          key: medKey,
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily:
                                'SelawikSemiLight',
                            color: Colors.grey[800],
                          )),
                      Expanded(
                          child: Divider(
                        color: Colors.grey[800],
                      )),
                    ],
                  ),
                ],
              ),
            )),
            medGV,
            SliverToBoxAdapter(
                child: Container(
                    height: MediaQuery.of(context)
                            .size
                            .height *
                        0.025)),
            SliverToBoxAdapter(
                child: Container(
              height: MediaQuery.of(context)
                      .size
                      .height *
                  0.05,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("DRIP TABLES ", //janky
                          key: dripKey,
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily:
                                'SelawikSemiLight',
                            color: Colors.grey[800],
                          )),
                      Expanded(
                          child: Divider(
                        color: Colors.grey[800],
                      )),
                    ],
                  ),
                ],
              ),
            )),
            dripGV,
            SliverToBoxAdapter(
                child: Container(
                    height: MediaQuery.of(context)
                            .size
                            .height *
                        0.025)),
          ],
        ));
  }

  Container drugTypeSelection() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.03,
        child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: Align(
                          alignment:
                              Alignment.bottomRight,
                          child: Container(
                              child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.teal),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0))),
                                  color: (state == 0) ? Colors.teal : Colors.white,
                                  textColor: (state == 0)
                                      ? Colors.white
                                      : Colors.teal,
                                  child: Text("          Medications          ",
                                      style: TextStyle(
                                          fontSize:
                                              25,
                                          fontFamily:'Selawik')),
                                  onPressed: () {
                                    Scrollable.ensureVisible(medKey.currentContext);
                                    setState(() {
                                      state = 0;
                                    });
                                  }))))),
              Container(
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.teal),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight:Radius.circular(20.0))),
                          color: (state == 1) ? Colors.teal : Colors.white,
                          textColor: (state == 1) ? Colors.white : Colors.teal,
                          child: Text("          Drip Tables          ",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontFamily:
                                      'Selawik')),
                          onPressed: () {
                            Scrollable.ensureVisible(
                                dripKey.currentContext);
                            setState(() {
                              state = 1;
                            });
                          })))
            ]));
  }

  Positioned bottomBar() {
    return Positioned(
        bottom: 0,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.06,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.teal,
                      child: Center(
                          child: Text(_timeString,
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'SelawikSemiBold',
                            color: Colors.white),
                      ))),
                  Container(
                      width:
                          MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.teal,
                      child: Center(
                          child: Text("Defibrillation (2 J/kg): ${widget.wt * 2} J",
                        style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'SelawikSemiBold',
                            color: Colors.white),
                      ))),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.teal,
                      child: Center(
                          child: Text(
                        "Cardioversion (Synchronized) (0.5 J/kg): ${widget.wt / 2} J",
                        style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'SelawikSemiBold',
                            color: Colors.white),
                      ))),
                ])));
  }

  Positioned drugPane(SliverGrid medGV, SliverGrid dripGV) {
    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height * 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.94,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            drugList(),
            drugTypeSelection()
          ])));
  }

  @override
  Widget build(BuildContext context) {
    populateSliverGrids();
    ListView timeline = generateTimeline();

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width),
          child: Stack(
            children: [
              timelineTab(timeline),
              drugPane(medGV, dripGV),
              bottomBar()]
    ))));
  }
}
