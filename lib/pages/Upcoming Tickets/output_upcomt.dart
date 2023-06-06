import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/pages/NewEntry/editentrypage.dart';
import 'package:async/async.dart';

class UpcomingTicketOutputScreen extends StatefulWidget {
  const UpcomingTicketOutputScreen({super.key});

  @override
  State<UpcomingTicketOutputScreen> createState() =>
      _UpcomingTicketOutputScreenState();
}

class _UpcomingTicketOutputScreenState
    extends State<UpcomingTicketOutputScreen> {
  List<Future<QuerySnapshot<Map<String, dynamic>>>> querySelect(
      String mode, String city) {
    var now = DateTime.now();
    var firstDateofMonth = DateTime(now.year, now.month, now.day);
    if (mode == 'From or to') {
      return [
        FirebaseFirestore.instance
            .collection("jd")
            .where("Jorneydate",
                isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
            .where('Fromplace', isEqualTo: city)
            .orderBy("Jorneydate")
            .get(),
        FirebaseFirestore.instance
            .collection("jd")
            .where("Jorneydate",
                isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
            .where('Fromplace', isEqualTo: city)
            .orderBy("Jorneydate")
            .get()
      ];
    } else {
      return mode == 'From'
          ? [
              FirebaseFirestore.instance
                  .collection("jd")
                  .where("Jorneydate",
                      isGreaterThanOrEqualTo:
                          DateTime(now.year, now.month, now.day))
                  .where('Fromplace', isEqualTo: city)
                  .where('Toplace', isEqualTo: city)
                  .orderBy("Jorneydate")
                  .get()
            ]
          : [
              FirebaseFirestore.instance
                  .collection("jd")
                  .where("Jorneydate",
                      isGreaterThanOrEqualTo:
                          DateTime(now.year, now.month, now.day))
                  .where('Fromplace', isEqualTo: city)
                  .where('Toplace', isEqualTo: city)
                  .orderBy("Jorneydate")
                  .get()
            ];
    }
  }

  Stream<List<QuerySnapshot>> streamSelect(String mode, String city) {
    var now = DateTime.now();
    var firstDateofMonth = DateTime(now.year, now.month, now.day);
    if (mode == 'From or to') {
      return StreamZip([
        FirebaseFirestore.instance
            .collection("jd")
            .where("Jorneydate",
                isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
            .where('Fromplace', isEqualTo: city)
            .orderBy("Jorneydate")
            .snapshots(),
        FirebaseFirestore.instance
            .collection("jd")
            .where("Jorneydate",
                isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day))
            .where('Toplace', isEqualTo: city)
            .orderBy("Jorneydate")
            .snapshots()
      ]);
    } else {
      return mode == 'From'
          ? StreamZip([
              FirebaseFirestore.instance
                  .collection("jd")
                  .where("Jorneydate",
                      isGreaterThanOrEqualTo:
                          DateTime(now.year, now.month, now.day))
                  .where('Fromplace', isEqualTo: city)
                  .orderBy("Jorneydate")
                  .snapshots()
            ])
          : StreamZip([
              FirebaseFirestore.instance
                  .collection("jd")
                  .where("Jorneydate",
                      isGreaterThanOrEqualTo:
                          DateTime(now.year, now.month, now.day))
                  .where('Toplace', isEqualTo: city)
                  .orderBy("Jorneydate")
                  .snapshots()
            ]);
    }
  }

  totalamount(String mode, String city) async {
    final snapshot = await querySelect(mode, city) as List<QuerySnapshot<Map>>;
    int sum = 0;
    for (var query in snapshot) {
      for (var data in query.docs) {
        sum += data.data()['rev'] as int;
      }
    }
    // snapshot.docs.forEach((doc) => sum += doc.data()['rev'] as int);
    print(_total);
    setState(() {
      _total = sum;
    });
  }

  int _total = 0;
  @override
  Widget build(BuildContext context) {
    //  final user = FirebaseAuth.instance.currentUser!;
    var mail = 'admin@gmail.com';
    var settings =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    var mode = settings['mode'];
    var city = settings['city'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MyAppBar2(title: '$mode : $city'),
            Expanded(
              child: StreamBuilder(
                  stream: streamSelect(mode!, city!),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Not Available",
                          style: TextStyle(fontSize: 30.0, color: Colors.grey),
                        ),
                      );
                    } else {
                      final now = DateTime.now();
                      List<QuerySnapshot> querySnapshotData = snapshot.data!;
                      if (querySnapshotData.length == 2) {
                        querySnapshotData[0]
                            .docs
                            .addAll(querySnapshotData[1].docs);
                      }
                      if (querySnapshotData[0].docs.isEmpty)
                        return const Center(
                          child: Text(
                            "Not Available",
                            style:
                                TextStyle(fontSize: 30.0, color: Colors.grey),
                          ),
                        );

                      if (querySnapshotData[0].docs.length == 0)
                        return const Center(
                          child: Text(
                            "Not Available",
                            style:
                                TextStyle(fontSize: 30.0, color: Colors.grey),
                          ),
                        );
                      print(querySnapshotData[0].docs);

                      return ListView(
                        shrinkWrap: true,
                        children: querySnapshotData[0].docs.map((document) {
                          DateTime jdate = document['Jorneydate'].toDate();
                          {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(19, 5, 19, 5),
                              child: Container(
                                width: 90,
                                height: 150,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 10, 30, 10),
                                  child: Column(
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
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            document['Amount'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
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
                                          ),
                                          // Text(
                                          //   document['Modeoftransport'],
                                          //   style: GoogleFonts.poppins(
                                          //       fontSize: 12,
                                          //       fontWeight: FontWeight.w400),
                                          // ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 20),
                                            child: Text(
                                              '${jdate.day}/${jdate.month}/${jdate.year}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 20, 21),
                                            child: Text(
                                              document['Traveltime'],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          (mail == "admin@gmail.com")
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
                                                                    totalamount(
                                                                        mode,
                                                                        city);
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
