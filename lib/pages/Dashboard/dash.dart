import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:travellog/pages/Dashboard/goaTicketOutput.dart';
import 'package:travellog/pages/Dashboard/searchResult.dart';
import 'package:travellog/pages/Dashboard/stayScreen.dart';
import 'package:travellog/pages/Dashboard/totalScreen.dart';
import 'package:travellog/pages/Settingss/settingspage.dart';

import '../../../../comps/buttons.dart';
import '../../../../comps/myappbar.dart';

class Dash extends StatefulWidget {
  const Dash({super.key});

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  //
  bool isLoading = true;
  void startTimer() {
    Timer.periodic(const Duration(seconds: 2), (t) {
      if (mounted) {
        setState(() {
          isLoading = false; //set loading to false
        });
      }
      t.cancel(); //stops the timer
    });
  }
  //

  int _total = 0;
  totalamount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('jd')
        .where('Bookingdate',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month))
        .where('Bookingdate',
            isLessThanOrEqualTo: DateTime(now.year, now.month + 1, 0))
        .orderBy('Bookingdate')
        .get();
    int sum = 0;
    snapshot.docs.forEach((doc) => sum += doc.data()['rev'] as int);
    print(_total);
    setState(() {
      _total = sum;
      bool isLoading = false;
    });
  }

  final now = DateTime.now();
  @override
  void initState() {
    super.initState();
    totalamount();
    startTimer();
    fetchOrigins();
    String currentMonth = DateFormat('MMMM').format(now);
    int currentYear = now.year;
  }

  String _journeyfilterfrom = "From";
  String _journeyfilterto = "To";

  String _bookingfilterfrom = "From";
  String _bookingfilterto = "To";

  final fromcitycontroller = TextEditingController();
  final tocitycontroller = TextEditingController();

  DateTime? selectedFromJourneyDate, selectedToJourneyDate;

  DateTime selectedFromBookingDate = DateTime(2020), //past
      selectedToBookingDate = DateTime(3000); //future

  bool cityLoading = true;

  List<String> cityList = [];

  Map<String, String> dateTypeList = {
    'Booking Date': 'Bookingdate',
    'Journey Date': 'Jorneydate'
  };

  fetchOrigins() async {
    cityList = [];
    var result =
        await FirebaseFirestore.instance.collection('OriginCities').get();
    for (var data in result.docs.first.get('cities')) {
      cityList.add(data);
    }
    print(cityList);
    if (mounted) {
      setState(() {
        cityLoading = false;
      });
    }
  }

  DateTime roundToLastMinuteOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59);
  }

  String? selectedDateType = 'Jorneydate';
  Query querySelect(TextEditingController fromcitycontroller,
      TextEditingController tocitycontroller) {
    var now = DateTime.now();

    // String currentMonth = DateFormat('MMMM').format(now);
    // int currentYear = now.year;
    // var firstDateofMonth = DateTime(now.year, now.month, 1);
    return fromcitycontroller.text.isEmpty &&
            tocitycontroller.text.isEmpty &&
            selectedFromJourneyDate == null &&
            selectedToJourneyDate == null
        ? FirebaseFirestore.instance.collection("jd").orderBy("Jorneydate")
        : fromcitycontroller.text.isNotEmpty && tocitycontroller.text.isNotEmpty
            ? FirebaseFirestore.instance
                .collection("jd")
                .where("Jorneydate",
                    isGreaterThanOrEqualTo: selectedFromJourneyDate)
                .where("Jorneydate", isLessThanOrEqualTo: selectedToJourneyDate)
                .where('Fromplace', isEqualTo: fromcitycontroller.text)
                .where('Toplace', isEqualTo: tocitycontroller.text)
                .orderBy("Jorneydate")
            : fromcitycontroller.text.isNotEmpty
                ? FirebaseFirestore.instance
                    .collection("jd")
                    .where("Jorneydate",
                        isGreaterThanOrEqualTo: selectedFromJourneyDate)
                    .where("Jorneydate",
                        isLessThanOrEqualTo: selectedToJourneyDate)
                    .where('Fromplace', isEqualTo: fromcitycontroller.text)
                    .orderBy("Jorneydate")
                : tocitycontroller.text.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection("jd")
                        .where("Jorneydate",
                            isGreaterThanOrEqualTo: selectedFromJourneyDate)
                        .where("Jorneydate",
                            isLessThanOrEqualTo: selectedToJourneyDate)
                        .where('Toplace', isEqualTo: tocitycontroller.text)
                        .orderBy("Jorneydate")
                    : FirebaseFirestore.instance
                        .collection("jd")
                        .where("Jorneydate",
                            isGreaterThanOrEqualTo: selectedFromJourneyDate)
                        .where("Jorneydate",
                            isLessThanOrEqualTo: selectedToJourneyDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const MyAppBar2(
              title: "Dashboard",
            ),
            Container(
                height: 70,
                width: 330,
                color: Colors.green.shade200,
                child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            NumberFormat.currency(
                                    decimalDigits: 0,
                                    name: 'Rs. ',
                                    locale: 'HI')
                                .format(_total),
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 27,
                                fontWeight: FontWeight.w700),
                            textScaleFactor: 1.0,
                          ))),
            const SizedBox(height: 10),

            !cityLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyButton3(
                          title: "In",
                          ontapp: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings: RouteSettings(arguments: {
                                      'mode': 'To',
                                      'city': cityList
                                    }),
                                    builder: (context) {
                                      return const GoaTicketOutputScreen();
                                    }));
                          }),
                      MyButton3(
                          title: "Out",
                          ontapp: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings: RouteSettings(arguments: {
                                      'mode': 'From',
                                      'city': cityList
                                    }),
                                    builder: (context) {
                                      return const GoaTicketOutputScreen();
                                    }));
                          }),
                    ],
                  )
                : Container(),

            MyButton3(
                title: "Stay",
                ontapp: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          settings: RouteSettings(arguments: cityList),
                          builder: (context) {
                            return const StayScreen();
                          }));
                }),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 3,
                ),
                Flexible(
                  flex: 9,
                  fit: FlexFit.loose,
                  child: DropdownButtonFormField(
                    //  selectedItemBuilder: (context) => [Text(selectedDateType!)],
                    value: selectedDateType,
                    autofocus: false,

                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    hint: const Text(
                      'Select date filter',
                      textScaleFactor: 1.0,
                    ),
                    items: dateTypeList.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.key),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFromBookingDate = DateTime(2020);
                        selectedToBookingDate = DateTime(3000);
                        selectedFromJourneyDate = selectedToJourneyDate = null;
                        _bookingfilterfrom = 'From';
                        _bookingfilterto = 'To';
                        selectedDateType = value;
                      });
                    },
                  ),
                ),
                const Spacer(
                  flex: 3,
                )
              ],
            ),

            //

            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.black26),
                        left: BorderSide(width: 1.0, color: Colors.black26),
                        right: BorderSide(width: 1.0, color: Colors.black26),
                        bottom: BorderSide(width: 1.0, color: Colors.black26),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                            child: Text(
                              _bookingfilterfrom,
                              textAlign: TextAlign.center,
                              textScaleFactor: 1.0,
                            ),
                            onTap: () {}),
                        IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.black87, size: 18),
                          onPressed: () async {
                            final DateTime? d;
                            if (selectedDateType == 'Jorneydate') {
                              d = await showDatePicker(
                                context: context,
                                initialDate:
                                    selectedFromJourneyDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(3000),
                              );
                            } else {
                              d = await showDatePicker(
                                context: context,
                                initialDate:
                                    selectedFromBookingDate == DateTime(2020)
                                        ? DateTime.now()
                                        : selectedFromBookingDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(3000),
                              );
                            }
                            if (d != null) {
                              if (selectedDateType != 'Jorneydate') {
                                selectedFromBookingDate = d;
                              } else {
                                selectedFromJourneyDate = d;
                              }
                              setState(() {
                                _bookingfilterfrom =
                                    DateFormat('dd-MM-yy').format(d!);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.black26),
                        left: BorderSide(width: 1.0, color: Colors.black26),
                        right: BorderSide(width: 1.0, color: Colors.black26),
                        bottom: BorderSide(width: 1.0, color: Colors.black26),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          child: Text(
                            _bookingfilterto,
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.black87, size: 18),
                          onPressed: () async {
                            final DateTime? d;
                            if (selectedDateType == 'Jorneydate') {
                              d = await showDatePicker(
                                context: context,
                                initialDate:
                                    selectedToJourneyDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(3000),
                              );
                            } else {
                              d = await showDatePicker(
                                context: context,
                                initialDate:
                                    selectedToBookingDate == DateTime(3000)
                                        ? DateTime.now()
                                        : selectedToBookingDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(3000),
                              );
                            }
                            if (d != null) {
                              if (selectedDateType != 'Jorneydate') {
                                selectedToBookingDate =
                                    roundToLastMinuteOfDay(d);
                              } else {
                                selectedToJourneyDate =
                                    roundToLastMinuteOfDay(d);
                              }
                              setState(() {
                                _bookingfilterto =
                                    DateFormat('dd-MM-yy').format(d!);
                              });

                              totalamount();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            //

            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: Row(
                children: [
                  Flexible(
                    child: TypeAheadFormField(
                      enabled: true,
                      hideOnError: true,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: fromcitycontroller,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: " From",
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
                          title: Text(
                            suggestion,
                            textScaleFactor: 1.0,
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        fromcitycontroller.text = suggestion;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: tocitycontroller,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: " To",
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
                          title: Text(
                            suggestion,
                            textScaleFactor: 1.0,
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        tocitycontroller.text = suggestion;
                      },
                    ),
                  ),
                ],
              ),
            ),

            //
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton3(
                  title: "Search",
                  ontapp: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(arguments: {
                            'query': querySelect(
                                fromcitycontroller, tocitycontroller),
                            'fromBookingdate': selectedFromBookingDate,
                            'toBookingdate': selectedToBookingDate,
                          }),
                          builder: (context) => const SearchResultScreen(),
                        ));
                  },
                ),
                MyButton3(
                  title: "Clear",
                  ontapp: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const Dash()));
                  },
                ),
              ],
            ),
            MyButton3(
              title: "Daily Total",
              ontapp: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const TotalScreen()));
              },
            ),
          ],
        ),
      )),
    );
  }
}
