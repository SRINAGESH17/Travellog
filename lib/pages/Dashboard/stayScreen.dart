import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/pages/DialyReport/dialyreport.dart';
import 'package:travellog/pages/NewEntry/editentrypage.dart';

class StayScreen extends StatefulWidget {
  const StayScreen({super.key});

  @override
  State<StayScreen> createState() => _StayScreenState();
}

class _StayScreenState extends State<StayScreen> {
  Future<List<DocumentSnapshot>> fetchAndCheck(List<String> cityList) async {
    List<DocumentSnapshot> customerResult = [];
    final CollectionReference ticketsRef =
        FirebaseFirestore.instance.collection('jd');

    final QuerySnapshot ticketsSnapshot = await ticketsRef
        .where('Jorneydate', isLessThan: DateTime.now())
        .orderBy('Jorneydate', descending: true)
        .get();

    final Map<String, DocumentSnapshot> latestTickets = {};

    for (final ticketDoc in ticketsSnapshot.docs) {
      final String customerName = ticketDoc.get('Customername');

      if (!latestTickets.containsKey(customerName)) {
        latestTickets[customerName] = ticketDoc;
      }
    }

    // Process the latest tickets
    for (final customerName in latestTickets.keys) {
      final DocumentSnapshot latestTicket = latestTickets[customerName]!;
      final String toPlace = latestTicket.get('Toplace');
      if (cityList.contains(toPlace)) {
        customerResult.add(latestTicket);
      }
      customerResult.sort(
        (a, b) => (b["Jorneydate"] as Timestamp).compareTo(a["Jorneydate"]),
      );

      print('Latest ticket for $customerName: $toPlace');
    }
    return customerResult;
  }

  @override
  Widget build(BuildContext context) {
    List<String> cityList =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    var user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MyAppBar2(title: '$cityList'),
            FutureBuilder(
                future: fetchAndCheck(cityList),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: const Text('No results'));
                  } else {
                    return Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.map((document) {
                          DateTime jdate = document['Jorneydate'].toDate();

                          DateTime date = document['Bookingdate'].toDate();

                          {
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
                                                                      docid: document
                                                                          .id),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .green
                                                                  .shade300,
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
                                                            builder:
                                                                (BuildContext
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
                                                                actions: <
                                                                    Widget>[
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
                                                                    child: const Text(
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
                                                                      setState(
                                                                          () {});
                                                                      Fluttertoast.showToast(
                                                                          backgroundColor: Colors
                                                                              .black54,
                                                                          msg:
                                                                              "Entry Deleted",
                                                                          toastLength: Toast
                                                                              .LENGTH_SHORT,
                                                                          gravity: ToastGravity
                                                                              .SNACKBAR,
                                                                          timeInSecForIosWeb:
                                                                              1,
                                                                          textColor: Colors
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
                                                                  .green
                                                                  .shade300,
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
                          }
                        }).toList(),
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
