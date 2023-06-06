import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/pages/Upcoming%20Tickets/output_upcomt.dart';


class UpcomingTicketSelectScreen extends StatefulWidget {
  const UpcomingTicketSelectScreen({super.key});

  @override
  State<UpcomingTicketSelectScreen> createState() =>
      _UpcomingTicketSelectScreenState();
}

class _UpcomingTicketSelectScreenState
    extends State<UpcomingTicketSelectScreen> {
  final cityController = TextEditingController();

  final toCityController = TextEditingController();

  final fromCityController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            MyAppBar2(title: 'Upcoming Tickets'),
            const SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From or To',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  SizedBox(
                    height: 20,
                  ),
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: fromCityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: " Choose a city",
                        // labelText: 'Country',
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      var countries = await FirebaseFirestore.instance
                          .collection('citynames')
                          .where('name', isGreaterThanOrEqualTo: pattern)
                          .where('name', isLessThan: pattern + 'z')
                          .get();
                      return countries.docs
                          .map((doc) => doc.data()['name'])
                          .toList();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(arguments: {
                                'mode': 'From or to',
                                'city': suggestion as String
                              }),
                              builder: (context) {
                                return UpcomingTicketOutputScreen();
                              }));
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From ',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  SizedBox(
                    height: 20,
                  ),
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: fromCityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: " Choose a city",
                        // labelText: 'Country',
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      var countries = await FirebaseFirestore.instance
                          .collection('citynames')
                          .where('name', isGreaterThanOrEqualTo: pattern)
                          .where('name', isLessThan: pattern + 'z')
                          .get();
                      return countries.docs
                          .map((doc) => doc.data()['name'])
                          .toList();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(arguments: {
                                'mode': 'From',
                                'city': suggestion as String
                              }),
                              builder: (context) {
                                return UpcomingTicketOutputScreen();
                              }));
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To',
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  SizedBox(
                    height: 20,
                  ),
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: fromCityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: " Choose a city",
                        // labelText: 'Country',
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      var countries = await FirebaseFirestore.instance
                          .collection('citynames')
                          .where('name', isGreaterThanOrEqualTo: pattern)
                          .where('name', isLessThan: pattern + 'z')
                          .get();
                      return countries.docs
                          .map((doc) => doc.data()['name'])
                          .toList();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(arguments: {
                                'mode': 'To',
                                'city': suggestion as String
                              }),
                              builder: (context) {
                                return UpcomingTicketOutputScreen();
                              }));
                    },
                  ),
                  SizedBox(
                    height: 500,
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}