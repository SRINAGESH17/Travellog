import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/cards.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/NewEntry/editentrypage.dart';
import 'package:travellog/revenue.dart';

class OwnerAllTickets extends StatefulWidget {
  const OwnerAllTickets({super.key});

  @override
  State<OwnerAllTickets> createState() => _OwnerAllTicketsState();
}

class _OwnerAllTicketsState extends State<OwnerAllTickets> {
  String _journeydate = 'Tap to select date';

  final amountController = TextEditingController();
  final fromcitycontroller = TextEditingController();
  final tocitycontroller = TextEditingController();
  final searchController = TextEditingController();
  String _journeyfilterfrom = "From";
  String _journeyfilterto = "To";

  String _bookingfilterfrom = "From";
  String _bookingfilterto = "To";

  int _total = 0;

  Future<void> _selectjourneyDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (d != null) {
      setState(() {
        _journeydate = new DateFormat.yMMMMd("en_US").format(d);
      });
    }
  }

  String _bookingdate = 'Tap to select date';
  Future<void> _selectbookingDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (d != null) {
      setState(() {
        _bookingdate = new DateFormat.yMMMMd("en_US").format(d);
      });
    }
  }

  String pickTime = 'Time';
  Future<void> _selecttime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context, //context of current state
    );

    if (pickedTime != null) {
      print(pickedTime.format(context)); //output 10:51 PM
      DateTime parsedTime =
          DateFormat.jm().parse(pickedTime.format(context).toString());
      //converting to DateTime so that we can further format on different pattern.
      print(parsedTime); //output 1970-01-01 22:53:00.000
      String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
      print(formattedTime);
      setState(() {
        pickTime = formattedTime;
      }); //output 14:59:00
      //DateFormat() is from intl package, you can format the time on any pattern you need.
    } else {
      print("Time is not selected");
    }
  }

  String? customername;
  List<String> _customernames = [];
  String? mode;
  List<String> _modeoftransport = [];
  String? fromcity;
  List<String> _fromcities = [];
  String? tocity;
  List<String> _tocities = [];

  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    totalamount();
    _getTotalDocuments();
    startTimer();

    final now = DateTime.now();

    // Create a query for documents with date >= today at midnight
    final todayQuery = FirebaseFirestore.instance.collection('jd').where(
        'createdAt ',
        isGreaterThanOrEqualTo:
            Timestamp.fromDate(DateTime(now.year, now.month, now.day)));

    // Sort the documents by date in ascending order
    // final sortedQuery = todayQuery.orderBy('createdAt');

    // // Stream the documents and listen for changes
    // _stream = sortedQuery.snapshots();

    FirebaseFirestore.instance
        .collection('Customerslist')
        .get()
        .then((snapshot) {
      List<String> customernames = [];
      snapshot.docs.forEach((doc) {
        customernames.add(doc.data()['CustomerName']);
      });
      setState(() {
        _customernames = customernames;
      });
    });

    FirebaseFirestore.instance
        .collection('modeoftransport')
        .get()
        .then((snapshot) {
      List<String> modes = [];
      snapshot.docs.forEach((doc) {
        modes.add(doc.data()['mode']);
      });
      setState(() {
        _modeoftransport = modes;
      });
    });

    FirebaseFirestore.instance.collection('citynames').get().then((snapshot) {
      List<String> fromcities = [];
      snapshot.docs.forEach((doc) {
        fromcities.add(doc.data()['name']);
      });
      setState(() {
        _fromcities = fromcities;
      });
    });

    FirebaseFirestore.instance.collection('citynames').get().then((snapshot) {
      List<String> tocities = [];
      snapshot.docs.forEach((doc) {
        tocities.add(doc.data()['name']);
      });
      setState(() {
        _tocities = tocities;
      });
    });
  }

  totalamount() async {
    final snapshot = await querySelect(fromcitycontroller, tocitycontroller)
        .get() as QuerySnapshot<Map>;
    int sum = 0;
    snapshot.docs.forEach((doc) => sum += doc.data()['rev'] as int);
    print(_total);
    setState(() {
      _total = sum;
    });
  }

  int _totalDocuments = 0;

  void _getTotalDocuments() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("jd").get();
    setState(() {
      _totalDocuments = querySnapshot.size;
    });
  }

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

  Query querySelect(TextEditingController fromcitycontroller,
      TextEditingController tocitycontroller) {
    var now = DateTime.now();
    var firstDateofMonth = DateTime(now.year, now.month, 1);
    return fromcitycontroller.text.isEmpty &&
            tocitycontroller.text.isEmpty &&
            selectedFromBookingDate == null &&
            selectedToBookingDate == null
        ? FirebaseFirestore.instance
            .collection("jd")
            .orderBy('createdAt', descending: true)
        : fromcitycontroller.text.isNotEmpty && tocitycontroller.text.isNotEmpty
            ? FirebaseFirestore.instance
                .collection("jd")
                .where('Toplace', isEqualTo: tocitycontroller.text)
                .orderBy('createdAt', descending: true)
            : fromcitycontroller.text.isNotEmpty
                ? FirebaseFirestore.instance
                    .collection("jd")
                    .where('Fromplace', isEqualTo: fromcitycontroller.text)
                    .orderBy('createdAt', descending: true)
                : tocitycontroller.text.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection("jd")
                        .where('Toplace', isEqualTo: tocitycontroller.text)
                        .orderBy('createdAt', descending: true)
                    : selectedFromBookingDate == null &&
                            selectedToBookingDate == null
                        ? FirebaseFirestore.instance
                            .collection("jd")
                            .orderBy('createdAt', descending: true)
                        : FirebaseFirestore.instance
                            .collection("jd")
                            .orderBy('createdAt', descending: true);
  }

  DateTime? selectedFromJourneyDate, selectedToJourneyDate;

  DateTime selectedFromBookingDate = DateTime(2020), //past
      selectedToBookingDate = DateTime(3000); //future

  Map<String, String> dateTypeList = {
    'Booking Date': 'Bookingdate',
    'Journey Date': 'Jorneydate'
  };
  String? selectedDateType = 'Jorneydate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MyAppBar2(
              title: "All Tickets",
            ),
            Text(
              "All Tickets is $_totalDocuments",
              style: GoogleFonts.poppins(
                  fontSize: 21, fontWeight: FontWeight.w600),
              textScaleFactor: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Container(
                  //     height: 60,
                  //     width: 300,
                  //     color: Colors.green.shade200,
                  //     child: Center(
                  //         child: isLoading
                  //             ? const CircularProgressIndicator()
                  //             : Text(
                  //                 '$_totalDocuments',
                  //                 style: GoogleFonts.poppins(
                  //                     color: Colors.black,
                  //                     fontSize: 26,
                  //                     fontWeight: FontWeight.w700),
                  //               ))),
                  const SizedBox(height: 10),
                  Container(
                      height: 60,
                      width: 300,
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
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700),
                                  textScaleFactor: 1.0,
                                ))),
                ],
              ),
            ),
            // SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Container(
            //       decoration: const BoxDecoration(
            //           border: Border(
            //             top: BorderSide(width: 1.0, color: Colors.black26),
            //             left: BorderSide(width: 1.0, color: Colors.black26),
            //             right: BorderSide(width: 1.0, color: Colors.black26),
            //             bottom: BorderSide(width: 1.0, color: Colors.black26),
            //           ),
            //           borderRadius: BorderRadius.all(Radius.circular(5))),
            //       child: Padding(
            //         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: <Widget>[
            //             InkWell(
            //                 child: Text(
            //                   _journeyfilterfrom,
            //                   textAlign: TextAlign.center,
            //                 ),
            //                 onTap: () {}),
            //             IconButton(
            //               icon: Icon(Icons.calendar_today,
            //                   color: Colors.black87, size: 18),
            //               onPressed: () async {
            //                 final DateTime? d = await showDatePicker(
            //                   context: context,
            //                   initialDate:
            //                       selectedFromJourneyDate ?? DateTime.now(),
            //                   firstDate: DateTime(2020),
            //                   lastDate: DateTime(3000),
            //                 );
            //                 if (d != null) {
            //                   selectedFromJourneyDate = d;

            //                   _journeyfilterfrom =
            //                       DateFormat('dd-MM-yy').format(d);
            //                   totalamount();
            //                 }
            //               },
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     Container(
            //       decoration: const BoxDecoration(
            //           border: Border(
            //             top: BorderSide(width: 1.0, color: Colors.black26),
            //             left: BorderSide(width: 1.0, color: Colors.black26),
            //             right: BorderSide(width: 1.0, color: Colors.black26),
            //             bottom: BorderSide(width: 1.0, color: Colors.black26),
            //           ),
            //           borderRadius: BorderRadius.all(Radius.circular(5))),
            //       child: Padding(
            //         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: <Widget>[
            //             InkWell(
            //               child: Text(
            //                 _journeyfilterto,
            //                 textAlign: TextAlign.center,
            //               ),
            //             ),
            //             IconButton(
            //               icon: Icon(Icons.calendar_today,
            //                   color: Colors.black87, size: 18),
            //               onPressed: () async {
            //                 final DateTime? d = await showDatePicker(
            //                   context: context,
            //                   initialDate:
            //                       selectedToJourneyDate ?? DateTime.now(),
            //                   firstDate: DateTime(2020),
            //                   lastDate: DateTime(3000),
            //                 );
            //                 if (d != null) {
            //                   selectedToJourneyDate = d;

            //                   _journeyfilterto =
            //                       DateFormat('dd-MM-yy').format(d);
            //                   totalamount();
            //                 }
            //               },
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     const Spacer(
            //       flex: 3,
            //     ),
            //     Flexible(
            //       flex: 5,
            //       fit: FlexFit.tight,
            //       child: Container(
            //         child: DropdownButtonFormField(
            //           //  selectedItemBuilder: (context) => [Text(selectedDateType!)],
            //           value: selectedDateType,
            //           autofocus: false,

            //           decoration: const InputDecoration(
            //             contentPadding: EdgeInsets.all(10),
            //             border: OutlineInputBorder(
            //                 borderSide: BorderSide(color: Colors.black26),
            //                 borderRadius: BorderRadius.all(Radius.circular(5))),
            //             focusedBorder: OutlineInputBorder(
            //                 borderSide: BorderSide(color: Colors.black26),
            //                 borderRadius: BorderRadius.all(Radius.circular(5))),
            //           ),
            //           hint: const Text('Select date filter'),
            //           items: dateTypeList.entries
            //               .map(
            //                 (e) => DropdownMenuItem(
            //                   value: e.value,
            //                   child: Text(e.key),
            //                 ),
            //               )
            //               .toList(),
            //           onChanged: (value) {
            //             setState(() {
            //               selectedDateType = value;
            //             });
            //           },
            //         ),
            //       ),
            //     ),
            //     const Spacer(
            //       flex: 3,
            //     )
            //   ],
            // ),

            // const SizedBox(height: 15),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Container(
            //       decoration: const BoxDecoration(
            //           border: Border(
            //             top: BorderSide(width: 1.0, color: Colors.black26),
            //             left: BorderSide(width: 1.0, color: Colors.black26),
            //             right: BorderSide(width: 1.0, color: Colors.black26),
            //             bottom: BorderSide(width: 1.0, color: Colors.black26),
            //           ),
            //           borderRadius: BorderRadius.all(Radius.circular(5))),
            //       child: Padding(
            //         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: <Widget>[
            //             InkWell(
            //                 child: Text(
            //                   _bookingfilterfrom,
            //                   textAlign: TextAlign.center,
            //                 ),
            //                 onTap: () {}),
            //             IconButton(
            //               icon: const Icon(Icons.calendar_today,
            //                   color: Colors.black87, size: 18),
            //               onPressed: () async {
            //                 final DateTime? d = await showDatePicker(
            //                   context: context,
            //                   initialDate:
            //                       selectedFromBookingDate == DateTime(2020)
            //                           ? DateTime.now()
            //                           : selectedFromBookingDate,
            //                   firstDate: DateTime(2020),
            //                   lastDate: DateTime(3000),
            //                 );
            //                 if (d != null) {
            //                   selectedFromBookingDate = d;

            //                   _bookingfilterfrom =
            //                       DateFormat('dd-MM-yy').format(d);
            //                   totalamount();
            //                 }
            //               },
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     Container(
            //       decoration: const BoxDecoration(
            //           border: Border(
            //             top: BorderSide(width: 1.0, color: Colors.black26),
            //             left: BorderSide(width: 1.0, color: Colors.black26),
            //             right: BorderSide(width: 1.0, color: Colors.black26),
            //             bottom: BorderSide(width: 1.0, color: Colors.black26),
            //           ),
            //           borderRadius: BorderRadius.all(Radius.circular(5))),
            //       child: Padding(
            //         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: <Widget>[
            //             InkWell(
            //               child: Text(
            //                 _bookingfilterto,
            //                 textAlign: TextAlign.center,
            //               ),
            //             ),
            //             IconButton(
            //               icon: const Icon(Icons.calendar_today,
            //                   color: Colors.black87, size: 18),
            //               onPressed: () async {
            //                 final DateTime? d = await showDatePicker(
            //                   context: context,
            //                   initialDate:
            //                       selectedToBookingDate == DateTime(3000)
            //                           ? DateTime.now()
            //                           : selectedToBookingDate,
            //                   firstDate: DateTime(2020),
            //                   lastDate: DateTime(3000),
            //                 );
            //                 if (d != null) {
            //                   selectedToBookingDate = d;

            //                   _bookingfilterto =
            //                       DateFormat('dd-MM-yy').format(d);
            //                   totalamount();
            //                 }
            //               },
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     Row(
            //       children: [
            //         Container(
            //           width: 40,
            //           height: 40,
            //           decoration: BoxDecoration(
            //               color: Colors.green.shade300,
            //               borderRadius: BorderRadius.circular(5)),
            //           child: IconButton(
            //               onPressed: () {
            //                 setState(() {});
            //               },
            //               icon: const Icon(Icons.filter_alt_rounded, size: 18)),
            //         ),
            //         const SizedBox(width: 8),
            //         GestureDetector(
            //           onTap: () {
            //             Navigator.pushReplacement(
            //                 context,
            //                 MaterialPageRoute(
            //                     builder: (BuildContext context) =>
            //                         const OwnerAllTickets()));
            //           },
            //           child: Container(
            //             width: 40,
            //             height: 40,
            //             decoration: BoxDecoration(
            //                 color: Colors.green.shade300,
            //                 borderRadius: BorderRadius.circular(5)),
            //             child: const Icon(Icons.delete, size: 15),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 15),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                // Flexible(
                //   child: TypeAheadFormField(
                //     enabled: true,
                //     hideOnError: true,
                //     textFieldConfiguration: TextFieldConfiguration(
                //       controller: fromcitycontroller,
                //       textCapitalization: TextCapitalization.words,
                //       decoration: InputDecoration(
                //         hintText: " From",
                //         // labelText: 'Country',
                //         fillColor: Colors.white,
                //         focusColor: Colors.white,
                //         border: OutlineInputBorder(),
                //       ),
                //     ),
                //     suggestionsCallback: (pattern) async {
                //       var countries = await FirebaseFirestore.instance
                //           .collection('citynames')
                //           .where('name', isGreaterThanOrEqualTo: pattern)
                //           .where('name', isLessThan: pattern + 'z')
                //           .get();
                //       return countries.docs
                //           .map((doc) => doc.data()['name'])
                //           .toList();
                //     },
                //     itemBuilder: (context, suggestion) {
                //       return ListTile(
                //         title: Text(suggestion),
                //       );
                //     },
                //     onSuggestionSelected: (suggestion) {
                //       fromcitycontroller.text = suggestion;
                //     },
                //   ),
                // ),
                // SizedBox(
                //   width: 10,
                // ),
                // Flexible(
                //   child: TypeAheadFormField(
                //     textFieldConfiguration: TextFieldConfiguration(
                //       controller: tocitycontroller,
                //       textCapitalization: TextCapitalization.words,
                //       decoration: InputDecoration(
                //         hintText: " To",
                //         // labelText: 'Country',
                //         fillColor: Colors.white,
                //         focusColor: Colors.white,
                //         border: OutlineInputBorder(),
                //       ),
                //     ),
                //     suggestionsCallback: (pattern) async {
                //       var countries = await FirebaseFirestore.instance
                //           .collection('citynames')
                //           .where('name', isGreaterThanOrEqualTo: pattern)
                //           .where('name', isLessThan: pattern + 'z')
                //           .get();
                //       return countries.docs
                //           .map((doc) => doc.data()['name'])
                //           .toList();
                //     },
                //     itemBuilder: (context, suggestion) {
                //       return ListTile(
                //         title: Text(suggestion),
                //       );
                //     },
                //     onSuggestionSelected: (suggestion) {
                //       tocitycontroller.text = suggestion;
                //     },
                //   ),
                // ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: TextField(
                controller: searchController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "   " + 'Search..',
                    hintStyle: TextStyle(color: Colors.grey[500])),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Row(
              children: [],
            ),
            Row(
              children: [],
            ),
            Expanded(
              child: StreamBuilder(
                  stream: querySelect(fromcitycontroller, tocitycontroller)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('No Data Found');
                    }
                    final now = DateTime.now();
                    if (!snapshot.data!.docs.any((element) {
                      DateTime date = selectedDateType != null
                          ? element['$selectedDateType'].toDate()
                          : element['Bookingdate'].toDate();

                      return ((element['Customername'] as String)
                                  .startsWith(searchController.text) &&
                              (date.isAfter(selectedFromBookingDate) ||
                                  date.isAtSameMomentAs(
                                      selectedFromBookingDate)) &&
                              (date.isBefore(selectedToBookingDate) ||
                                  date.isAtSameMomentAs(selectedToBookingDate)))
                          ? true
                          : false;
                    })) return const Text('No Data Found');
                    snapshot.data!.docs.sort(
                        (a, b) => a['Jorneydate'].compareTo(b['Jorneydate']));
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map((document) {
                        DateTime jdiate = document['Jorneydate'].toDate();
                        DateTime date = selectedDateType != null
                            ? document['$selectedDateType'].toDate()
                            : document['Bookingdate'].toDate();

                        if ((document['Customername'] as String)
                                .startsWith(searchController.text) &&
                            (date.isAfter(selectedFromBookingDate) ||
                                date.isAtSameMomentAs(
                                    selectedFromBookingDate)) &&
                            (date.isBefore(selectedToBookingDate) ||
                                date.isAtSameMomentAs(selectedToBookingDate))) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(19, 5, 19, 5),
                            child: Container(
                              height: MediaQuery.of(context).size.height * .22,
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
                                              '${jdiate.day}/${jdiate.month}/${jdiate.year}',
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
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 0),
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

class MyPDFViewer extends StatelessWidget {
  final String url;

  MyPDFViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(
      url,
    );
  }
}
