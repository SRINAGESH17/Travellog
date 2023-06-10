import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travellog/comps/myappbar.dart';

class TotalScreen extends StatefulWidget {
  const TotalScreen({super.key});

  @override
  State<TotalScreen> createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  Future<Map<String, int>> ticketDisplay() async {
    var snapshot = await FirebaseFirestore.instance.collection("jd").get();
    Map<String, int> dayCount = {};
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    int difference = endOfMonth.difference(startOfMonth).inDays;
    for (int i = 0; i < difference + 1; i++) {
      dayCount[DateFormat('dd-MM-yy')
          .format(startOfMonth.add(Duration(days: i)))] = 0;
    }
    for (var doc in snapshot.docs) {
      // var date = data['Bookingdate'].toDate();
      var date = doc[dateType].toDate();
      date = DateFormat('dd-MM-yy').format(date);
      if (dayCount.containsKey(date)) {
        dayCount[date] = dayCount[date]! + doc['rev'] as int;
      }
    }

    return dayCount;
  }

  var dateType = 'Bookingdate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MyAppBar2(title: 'Total'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: <Widget>[
                    Radio(
                      value: 'Bookingdate',
                      groupValue: dateType,
                      onChanged: (value) {
                        setState(() {
                          dateType = value!;
                        });
                      },
                    ),
                    Text(
                      'Booking Date',
                      textScaleFactor: 0.8,
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(
                      value: 'Jorneydate',
                      groupValue: dateType,
                      onChanged: (value) {
                        setState(() {
                          dateType = value!;
                        });
                      },
                    ),
                    Text(
                      'Journey Date',
                      textScaleFactor: 0.8,
                    ),
                  ],
                ),
              ],
            ),
            FutureBuilder(
              future: ticketDisplay(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Column(
                        children: [
                          Table(
                            border: TableBorder.all(width: 1),
                            children: [
                              TableRow(children: [
                                Center(
                                  child: Text(
                                    ' BOOKING DATE',
                                    style: TextStyle(
                                        fontFamily: 'Calibri',
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                65,
                                        fontWeight: FontWeight.w700),
                                    textScaleFactor: 1.0,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    ' TOTAL',
                                    style: TextStyle(
                                        fontFamily: 'Calibri',
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                65,
                                        fontWeight: FontWeight.w700),
                                    textScaleFactor: 1.0,
                                  ),
                                ),
                              ]),
                              ...snapshot.data!.entries.map(
                                (entry) {
                                  return TableRow(children: [
                                    Center(
                                      child: Text(
                                        ' ' + entry.key,
                                        style: TextStyle(
                                            fontFamily: 'Calibri',
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                70,
                                            fontWeight: FontWeight.w700),
                                        textScaleFactor: 1.0,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        entry.value == 0
                                            ? ''
                                            : '${entry.value} ',
                                        style: TextStyle(
                                            fontFamily: 'Calibri',
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                70,
                                            fontWeight: FontWeight.w700),
                                        textScaleFactor: 1.0,
                                      ),
                                    ),
                                  ]);
                                },
                              ).toList(),
                            ],
                          ),
                          Table(
                            children: [
                              TableRow(children: [
                                Container(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    ' ${snapshot.data!.values.fold(0, (previousValue, element) => previousValue + element)} ',
                                    style: TextStyle(
                                        fontFamily: 'Calibri',
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                65,
                                        fontWeight: FontWeight.w700),
                                    textScaleFactor: 1.0,
                                  ),
                                ),
                              ])
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
