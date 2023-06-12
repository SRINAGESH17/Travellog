import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/pages/DialyReport/dialyreport.dart';
import 'package:travellog/pages/NewEntry/editentrypage.dart';
import 'package:travellog/pages/NewEntry/newentry.dart';

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
      if (cityList.contains(toPlace) &&
          latestTicket['TypeOFGuest'] != 'Cancel') {
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
    int sno = 1;
    var user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyAppBar2(title: '$cityList'),
              FutureBuilder(
                  future: fetchAndCheck(cityList),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No results'));
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: Table(
                          defaultColumnWidth: IntrinsicColumnWidth(),
                          border: TableBorder.all(width: 1),
                          children: [
                            TableRow(children: [
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: const Center(child: Text('SL NO'))),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: const Center(child: Text('NAME'))),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: const Center(child: Text('DOJ'))),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: const Center(child: Text('TIME')),
                              ),
                              Container()
                            ]),
                            ...snapshot.data!.map((e) {
                              var jdate =
                                  (e.get('Jorneydate') as Timestamp).toDate();
                              return TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text('${sno++}')),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(e.get('Customername')),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                      child: Text(
                                          '${jdate.day}/${jdate.month}/${jdate.year}')),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      Center(child: Text(e.get('Traveltime'))),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  decoration:
                                      const BoxDecoration(border: Border()),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade300,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NewEntry(
                                                  customerName:
                                                      e.get('Customername')),
                                            ));
                                      },
                                      child: const Text(
                                        'R',
                                        style: TextStyle(color: Colors.black),
                                      )),
                                )
                              ]);
                            })
                          ],
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
