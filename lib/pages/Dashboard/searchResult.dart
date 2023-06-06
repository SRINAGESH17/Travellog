// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/pages/Dashboard/dateViewScreen.dart';
import 'package:travellog/pages/NewEntry/editentrypage.dart';

import '../DialyReport/dialyreport.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool isLoading = true;
  Future<List> totalamount(
      Query query, DateTime fromBookingDate, DateTime toBookingDate) async {
    var snapshot = await query.get();

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
    for (var data in snapshot.docs) {
      var date = data['Bookingdate'].toDate();
      var journeyDate = data['Jorneydate'].toDate();
      journeyDate = DateFormat('dd/MM/yy').format(journeyDate);
      if ((date.isAfter(fromBookingDate) ||
              date.isAtSameMomentAs(fromBookingDate)) &&
          (date.isBefore(toBookingDate) ||
              date.isAtSameMomentAs(toBookingDate))) {
        sum += data['rev'] as int;
        totalTicketCount++;
        if (dayCount.containsKey(journeyDate)) {
          dayCount[journeyDate] = dayCount[journeyDate]! + 1;
        }
      }
    }
    return [sum, totalTicketCount, dayCount, snapshot.docs];
  }

  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    var settings =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Query query = settings['query'];
    var selectedFromBookingDate = settings['fromBookingdate'];
    var selectedToBookingDate = settings['toBookingdate'];
    print(query.parameters);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MyAppBar2(
              title: "Filtered Result",
            ),
            FutureBuilder(
              future: totalamount(
                  query, selectedFromBookingDate, selectedToBookingDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  Map<String, int> dayCountMap = snapshot.data![2];
                  return Column(
                    children: [
                      Container(
                          height: 70,
                          width: 330,
                          color: Colors.green.shade200,
                          child: Center(
                              child: Text(
                            NumberFormat.currency(
                                    decimalDigits: 0,
                                    name: 'Rs. ',
                                    locale: 'HI')
                                .format(snapshot.data![0]),
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 27,
                                fontWeight: FontWeight.w700),
                            textScaleFactor: 1.0,
                          ))),
                      const SizedBox(height: 10),
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
                                                guestFilter: false,
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
                          ))
                    ],
                  );
                }
              },
            ),
            Expanded(
              child: StreamBuilder(
                  stream: query.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('No Data Found');
                    }
                    final now = DateTime.now();

                    if (!snapshot.data!.docs.any((element) {
                      // DateTime date = selectedDateType != null
                      //     ? element['$selectedDateType'].toDate()
                      //     : element['Bookingdate'].toDate();

                      DateTime date = element['Bookingdate'].toDate();

                      return
                          //  ((element['Customername'] as String)
                          //             .startsWith(searchController.text) &&
                          ((date.isAfter(selectedFromBookingDate) ||
                                      date.isAtSameMomentAs(
                                          selectedFromBookingDate)) &&
                                  (date.isBefore(selectedToBookingDate) ||
                                      date.isAtSameMomentAs(
                                          selectedToBookingDate)))
                              ? true
                              : false;
                    })) return const Text('No Data Found');
                    snapshot.data!.docs.sort(
                        (a, b) => a['Jorneydate'].compareTo(b['Jorneydate']));
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map((document) {
                        DateTime jdate = document['Jorneydate'].toDate();
                        // DateTime date = selectedDateType != null
                        //     ? document['$selectedDateType'].toDate()
                        //     : document['Bookingdate'].toDate();
                        DateTime date = document['Bookingdate'].toDate();

                        if
                            //  ((document['Customername'] as String)
                            //         .startsWith(searchController.text) &&
                            ((date.isAfter(selectedFromBookingDate) ||
                                    date.isAtSameMomentAs(
                                        selectedFromBookingDate)) &&
                                (date.isBefore(selectedToBookingDate) ||
                                    date.isAtSameMomentAs(
                                        selectedToBookingDate))) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(19, 5, 19, 5),
                            child: Container(
                              height: MediaQuery.of(context).size.height * .24,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  builder: (context, snapshot) {
                                                    if (document["ticketDoc"] ==
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
                                                  builder: (context, snapshot) {
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
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 20),
                                            child: Text(
                                              '${jdate.day}/${jdate.month}/${jdate.year}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 20, 21),
                                            child: Text(
                                              document['Traveltime'],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                          const SizedBox(width: 5),

                                          //  view doc

                                          (user?.email == "admin@gmail.com")
                                              ? Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute<
                                                              void>(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                EditEntryPage(
                                                                    docid:
                                                                        document
                                                                            .id),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .green.shade300,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: const Icon(
                                                            Icons.edit,
                                                            size: 15),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        showDialog<void>(
                                                          context: context,
                                                          barrierDismissible:
                                                              false, // user must tap button!
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              // <-- SEE HERE
                                                              title: const Text(
                                                                  'Delete Entry'),
                                                              content:
                                                                  const SingleChildScrollView(
                                                                child: Text(
                                                                    'Are you sure want to Entry?'),
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                          'No'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                          'Yes'),
                                                                  onPressed:
                                                                      () async {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'jd')
                                                                        .doc(document
                                                                            .id)
                                                                        .delete();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();

                                                                    Fluttertoast.showToast(
                                                                        backgroundColor:
                                                                            Colors
                                                                                .black54,
                                                                        msg:
                                                                            "Entry Deleted",
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity
                                                                                .SNACKBAR,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        textColor:
                                                                            Colors
                                                                                .white,
                                                                        fontSize:
                                                                            16.0);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .green.shade300,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: const Icon(
                                                            Icons.delete,
                                                            size: 15),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(),
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
                        } else {
                          return Container();
                        }
                      }).toList(),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
