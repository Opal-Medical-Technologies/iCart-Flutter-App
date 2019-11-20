

import 'package:flutter/material.dart';

void main() => runApp(MyApp());



class DrugState extends State<Drug> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text("Epinephrine"),//change to generic drug input
          Text("2mg/100ml in DSW/NS (20mcg/ml"), //change to generic text
          Expanded(
            child: Row(
              children:[
                Column(
                  children:[
                    Text("DOSE (mcg/kg/min)"),
                    Row(
                      children:[
                        Column(
                          children:[
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade800
                              ),
                              label: Text("0.1")
                            ),
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade800
                              ),
                              label: Text("0.1")
                            )
                          ]
                        ),
                        Column(
                          children:[
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade800
                              ),
                              label: Text("0.1")
                            ),
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade800
                              ),
                              label: Text("0.1")
                            )
                          ]
                        ),
                        Column(
                          children:[
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade800
                              ),
                              label: Text("0.1")
                            ),
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade800
                              ),
                              label: Text("0.1")
                            )
                          ]
                        )
                      ]
                    )
                  ]
                ),
                Column(
                  children:[
                    Text("Rate (ml/hour)"),
                    Text("0.9")
                  ]

                )
              ]
            )
          )
        ]
      )
    );
  }
}

class Drug extends StatefulWidget {
  @override
  DrugState createState() => DrugState();
}

class TimeLineState extends State<TimeLine> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child:Column(
        children:[
          Text("TIMELINE"),
          ListView(
            children: [
              Row(
                children:[
                  Column(
                    children:[
                      Text(
                        "Epinephrine",//replace with generic drug name
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Row(
                        children:[
                          Text("12:32 am"), //change to generic time
                          Text("20 mg") //change to generic dosage
                        ]
                      )
                    ]
                  ),
                  IconButton(
                    //TODO implement later
                  )
                ]
              ),
              Row(
                children:[
                  Column(
                    children:[
                      Text(
                        "Epinephrine",//replace with generic drug name
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Row(
                        children:[
                          Text("12:32 am"), //change to generic time
                          Text("20 mg") //change to generic dosage
                        ]
                      )
                    ]
                  ),
                  IconButton(
                    //TODO implement later
                  )
                ]
              ),
              Row(
                children:[
                  Column(
                    children:[
                      Text(
                        "Epinephrine",//replace with generic drug name
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Row(
                        children:[
                          Text("12:32 am"), //change to generic time
                          Text("20 mg") //change to generic dosage
                        ]
                      )
                    ]
                  ),
                  IconButton(
                    //TODO implement later
                  )
                ]
              ),
              Row(
                children:[
                  Column(
                    children:[
                      Text(
                        "Epinephrine",//replace with generic drug name
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Row(
                        children:[
                          Text("12:32 am"), //change to generic time
                          Text("20 mg") //change to generic dosage
                        ]
                      )
                    ]
                  ),
                  IconButton(
                    //TODO implement later
                  )
                ]
              ),
              Row(
                children:[
                  Column(
                    children:[
                      Text(
                        "Epinephrine",//replace with generic drug name
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Row(
                        children:[
                          Text("12:32 am"), //change to generic time
                          Text("20 mg") //change to generic dosage
                        ]
                      )
                    ]
                  ),
                  IconButton(
                    //TODO implement later
                  )
                ]
              ),
              Row(
                children:[
                  Column(
                    children:[
                      Text(
                        "Epinephrine",//replace with generic drug name
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Row(
                        children:[
                          Text("12:32 am"), //change to generic time
                          Text("20 mg") //change to generic dosage
                        ]
                      )
                    ]
                  ),
                  IconButton(
                    //TODO implement later
                  )
                ]
              )
            ]
          )
        ]
      )
    );
  }
}

class TimeLine extends StatefulWidget {
  @override
  TimeLineState createState() => TimeLineState();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //bottom of screen
    Widget bottom = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade800
            ),
            label: Text("10:32 am")
          ),
          Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade800
            ),
            label: Text("Defibrillation (2 J/kg):")
          ),
          Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade800
            ),
            label: Text("90J")
          ),
          Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade800
            ),
            label: Text("Cardioversion (Synchronized) (0.5 J/kg)")
          ),
          Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade800
            ),
            label: Text("22.5 J")
          )
        ]
      )
    )
    //top center of screen
    Widget topcenter = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Atropine',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'MAX TOTAL DOSE OF 1mg',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Text('38kg'),
          Text('10 yrs'),
        ],
      ),
    );
    return MaterialApp(
      title: 'iCart',
      home: Scaffold(
        appBar: AppBar(
          title: Text('iCart App - version 1.2'),
        ),
          body: Column(
            children: [
              topcenter
            ],
          ),
        ),
      ),
    );
  }
}