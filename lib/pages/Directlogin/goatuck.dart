// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/pages/Dashboard/dateViewScreen.dart';
import 'package:travellog/pages/NewEntry/editentrypage.dart';
import 'package:async/async.dart';

import '../DialyReport/dialyreport.dart';

class GoaTic2 extends StatefulWidget {
  const GoaTic2({super.key});

  @override
  State<GoaTic2> createState() => _GoaTic2State();
}

class _GoaTic2State extends State<GoaTic2> {
  bool isDualStream = false;
  bool isLoading = true;

  Future<List<QuerySnapshot<Map<String, dynamic>>>> querySelect(
      String mode, List<String> cityList) async {
    var now = DateTime.now();

    var firstDateofMonth = DateTime(now.year, now.month, now.day);
    if (mode == 'From or to') {
      return [
        await FirebaseFirestore.instance
            .collection("jd")
            .where("Jorneydate",
                isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
            .where('Fromplace', whereIn: cityList)
            .orderBy("Jorneydate")
            .get(),
        await FirebaseFirestore.instance
            .collection("jd")
            .where("Jorneydate",
                isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
            .where('Toplace', whereIn: cityList)
            .orderBy("Jorneydate")
            .get()
      ];
    } else {
      return mode == 'From'
          ? [
              await FirebaseFirestore.instance
                  .collection("jd")
                  .where("Jorneydate",
                      isGreaterThanOrEqualTo:
                          DateTime(now.year, now.month, now.day))
                  .where('Fromplace', whereIn: cityList)
                  .orderBy("Jorneydate")
                  .get()
            ]
          : [
              await FirebaseFirestore.instance
                  .collection("jd")
                  .where("Jorneydate",
                      isGreaterThanOrEqualTo:
                          DateTime(now.year, now.month, now.day))
                  .where('Toplace', whereIn: cityList)
                  .orderBy("Jorneydate")
                  .get()
            ];
    }
  }

  Stream<List<DocumentSnapshot>> stream(
      String mode, List<String> cityList) async* {
    var now = DateTime.now();

    Stream<QuerySnapshot> stream1 = FirebaseFirestore.instance
        .collection("jd")
        .where("Jorneydate",
            isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
        .where('Toplace', whereIn: cityList)
        .orderBy("Jorneydate")
        .snapshots();
    Stream<QuerySnapshot> stream2 = FirebaseFirestore.instance
        .collection("jd")
        .where("Jorneydate",
            isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
        .where('Fromplace', whereIn: cityList)
        .orderBy("Jorneydate")
        .snapshots();
    yield* CombineLatestStream.combine2(stream1, stream2,
        (QuerySnapshot a, QuerySnapshot b) => [...a.docs, ...b.docs]);
  }

  Stream<dynamic> streamSelect(String mode, List<String> cityList) {
    var now = DateTime.now();
    if (mode == 'From or to') {
      isDualStream = true;
      return stream(mode, cityList);
    } else {
      return mode == 'From'
          ? FirebaseFirestore.instance
              .collection("jd")
              .where("Jorneydate",
                  isGreaterThanOrEqualTo:
                      DateTime(now.year, now.month, now.day))
              .where('Fromplace', whereIn: cityList)
              .orderBy("Jorneydate")
              .snapshots()
          : FirebaseFirestore.instance
              .collection("jd")
              .where("Jorneydate",
                  isGreaterThanOrEqualTo:
                      DateTime(now.year, now.month, now.day))
              .where('Toplace', whereIn: cityList)
              .orderBy("Jorneydate")
              .snapshots();
    }
  }

  var numberOfTickets = 0;

  Future<List> totalamount(
    String mode,
    List<String> cityList,
  ) async {
    var snapshotList = await querySelect(mode, cityList);
    var snapshot = [];
    for (var item in snapshotList) {
      snapshot.addAll(item.docs);
    }

    int sum = 0;

    int totalTicketCount = 0;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));
    DateTime dayAfter = tomorrow.add(const Duration(days: 1));
    Map<String, int> dayCount = {
      DateFormat('dd/MM/yy').format(today): 0,
      DateFormat('dd/MM/yy').format(tomorrow): 0,
      DateFormat('dd/MM/yy').format(dayAfter): 0
    };
    print(dayCount);
    for (var data in snapshot) {
      if (data['TypeOFGuest'] == 'Guest' ||
          (data['Modeoftransport'] == 'Flight' && data['rev'] <= 1000)) {
        continue;
      }
      var journeyDateTime = data['Jorneydate'].toDate() as DateTime;
      var journeyDate = data['Jorneydate'].toDate();
      journeyDate = DateFormat('dd/MM/yy').format(journeyDate);
      print(journeyDate);
      sum += data['rev'] as int;

      if (dayCount.containsKey(journeyDate) && journeyDateTime.isAfter(now)) {
        dayCount[journeyDate] = dayCount[journeyDate]! + 1;
        totalTicketCount++;
      }
    }

    return [sum, totalTicketCount, dayCount, snapshot];
  }

  @override
  Widget build(BuildContext context) {
    var settings =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var mode = settings['mode'];
    var cityList = settings['city'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MyAppBar2(title: '$mode : $cityList'),
            FutureBuilder(
              future: totalamount(mode!, cityList),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  Map<String, int> dayCountMap = snapshot.data![2];
                  return Column(
                    children: [
                      Container(
                          height: 60,
                          width: 300,
                          color: Colors.green.shade200,
                          child: Center(
                              child: Text(
                            snapshot.data![1].toString(),
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 26,
                                fontWeight: FontWeight.w700),
                            textScaleFactor: 1.0,
                          ))),
                      const SizedBox(height: 10),
                      // Container(
                      //     height: 60,
                      //     width: 300,
                      //     color: Colors.green.shade200,
                      //     child: Center(
                      //         child: Text(
                      //       'Rs. ${snapshot.data![0].toString()}',
                      //       style: GoogleFonts.poppins(
                      //           color: Colors.black,
                      //           fontSize: 26,
                      //           fontWeight: FontWeight.w700),
                      //     ))),
                      Container(
                          width: 300,
                          color: Colors.green.shade200,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 10),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...dayCountMap.entries
                                      .map((entry) => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Spacer(
                                                flex: 4,
                                              ),
                                              Text(
                                                '${entry.key}',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                '  :  ',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                '${entry.value}',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textScaleFactor: 1.0,
                                              ),
                                              Spacer(
                                                flex: 4,
                                              )
                                            ],
                                          ))
                                      .toList(),
                                  Row(
                                    children: [
                                      Spacer(),
                                      InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              settings:
                                                  RouteSettings(arguments: {
                                                'ticketList': snapshot.data![3]
                                              }),
                                              builder: (context) =>
                                                  DateViewScreen(
                                                guestFilter: true,
                                                todayFilter: true,
                                              ),
                                            ));
                                          },
                                          child: Text(
                                            'See more ->',
                                            style:
                                                TextStyle(color: Colors.blue),
                                            textScaleFactor: 1.0,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ],
                  );
                }
              },
            ),
            Expanded(
              child: StreamBuilder(
                  stream: streamSelect(mode, cityList),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    // else if (snapshot.data!.docs.isEmpty) {
                    //   return const Center(
                    //     child: Text(
                    //       "Not Available",
                    //       style: TextStyle(fontSize: 30.0, color: Colors.grey),
                    //     ),
                    //   );
                    // }
                    else {
                      final now = DateTime.now();
                      List<DocumentSnapshot> querySnapshotData = [];
                      if (isDualStream == true) {
                        querySnapshotData = snapshot.data;
                      } else {
                        querySnapshotData =
                            (snapshot.data as QuerySnapshot).docs;
                      }

                      if (querySnapshotData.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Data",
                            style:
                                TextStyle(fontSize: 30.0, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        children: querySnapshotData.map((document) {
                          DateTime jdate = document['Jorneydate'].toDate();
                          if (document['TypeOFGuest'] == 'Guest' ||
                              (document['Modeoftransport'] == 'Flight' &&
                                  document['rev'] <= 1000) ||
                              jdate.isBefore(now)) {
                            return Container();
                          } else {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(19, 5, 19, 5),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .24,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 18, 30, 18),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            document['Customername'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                            textScaleFactor: 1.0,
                                          ),
                                          Text(
                                            document['Amount'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400),
                                            textScaleFactor: 1.0,
                                          ),
                                        ],
                                      ),
                                      if (document['TypeOFGuest'] == "Guest")
                                        Text(
                                          document['TypeOFGuest'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400),
                                          textScaleFactor: 1.0,
                                        ),
                                      const SizedBox(height: 0),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              document['Fromplace'] +
                                                  " to " +
                                                  document['Toplace'],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                              textScaleFactor: 1.0,
                                            ),
                                            Row(
                                              children: [
                                                StreamBuilder<Object>(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection("jd")
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (document[
                                                              "ticketDoc"] ==
                                                          "") {
                                                        return Container();
                                                      }

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyPDFViewer(
                                                                      url: document[
                                                                          'ticketDoc']),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Image.asset(
                                                            "assets/icons/pdf1.png",
                                                            scale: 1.5,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                SizedBox(width: 5),
                                                StreamBuilder<Object>(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection("jd")
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (document[
                                                              "ticketDoc2"] ==
                                                          "") {
                                                        return Container();
                                                      }

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyPDFViewer(
                                                                      url: document[
                                                                          'ticketDoc2']),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Image.asset(
                                                            "assets/icons/pdf2.png",
                                                            scale: 1.5,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 20),
                                              child: Text(
                                                '${jdate.day}/${jdate.month}/${jdate.year}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                textScaleFactor: 1.0,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 20, 21),
                                              child: Text(
                                                document['Traveltime'],
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                textScaleFactor: 1.0,
                                              ),
                                            ),
                                            const SizedBox(width: 5),

                                            //  view doc
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 9),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            document['Modeoftransport'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400),
                                            textScaleFactor: 1.0,
                                          ),
                                          if (document['Reference'] != "")
                                            Text(
                                              "Ref : " + document['Reference'],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400),
                                              textScaleFactor: 1.0,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
