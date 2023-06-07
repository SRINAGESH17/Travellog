import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/myappbar.dart';

class StayScreen extends StatelessWidget {
  const StayScreen({super.key});

  Future<List<String>> fetchAndCheck(List<String> cityList) async {
    List<String> customerResult = [];
    final CollectionReference ticketsRef =
        FirebaseFirestore.instance.collection('JorneyDetials');

    // Query all tickets sorted by journeydate in descending order
    final QuerySnapshot ticketsSnapshot = await ticketsRef
        .where('Jorneydate', isLessThan: DateTime.now())
        .orderBy('Jorneydate', descending: true)
        .get();

    // Create a map to store the latest ticket for each customer
    final Map<String, DocumentSnapshot> latestTickets = {};

    // Process each ticket
    for (final ticketDoc in ticketsSnapshot.docs) {
      final String customerName = ticketDoc.get('Customername');

      // Check if the customer already has a latest ticket
      if (!latestTickets.containsKey(customerName)) {
        latestTickets[customerName] = ticketDoc;
      }
    }

    // Process the latest tickets
    for (final customerName in latestTickets.keys) {
      final DocumentSnapshot latestTicket = latestTickets[customerName]!;
      final String toPlace = latestTicket.get('Toplace');
      if (cityList.contains(toPlace)) {
        customerResult.add(customerName);
      }

      print('Latest ticket for $customerName: $toPlace');
    }
    return customerResult;
  }

  @override
  Widget build(BuildContext context) {
    List<String> cityList =
        ModalRoute.of(context)!.settings.arguments as List<String>;

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
                        children: snapshot.data!.map((customername) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                            child: Container(
                              width: 100,
                              height: MediaQuery.of(context).size.height * .1,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 10, 30, 10),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          customername,
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                          textScaleFactor: 1.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
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
