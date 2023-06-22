import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/auth/loginpage.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/datepicker.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:intl/intl.dart';
import 'package:travellog/comps/textfields.dart';

import 'package:travellog/pages/homepage.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  // late DateTime _selectedDate = DateTime.now();

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //   }
  // }

  final amountController = TextEditingController();
  final nameController = TextEditingController();

  String _journeydate = 'Tap to select date';
  DateTime _pickedjourneydate = DateTime.now();
  Future<void> _selectjourneyDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (d != null) {
      setState(() {
        _journeydate = new DateFormat.yMMMMd("en_US").format(d);
        _pickedjourneydate = d;
      });
    }
  }

  String _bookingdate = 'Tap to select date';
  DateTime _pickedbookingdate = DateTime.now();
  Future<void> _selectbookingDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (d != null) {
      setState(() {
        _bookingdate = DateFormat.yMMMMd("en_US").format(d);
        _pickedbookingdate = d;
      });
    }
  }

  var pickTime = 'Time';
  String? _time;

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
        pickTime = formattedTime as String;
        _time = formattedTime;
      }); //output 14:59:00
      //DateFormat() is from intl package, you can format the time on any pattern you need.
    } else {
      print("Time is not selected");
    }
  }

  String? mode;
  List<String> _modeoftransport = [];
  String? fromcity;
  List<String> _fromcities = [];
  String? tocity;
  List<String> _tocities = [];
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  @override
  void initState() {
    super.initState();

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

  final fromcitycontroller = TextEditingController();
  final tocitycontroller = TextEditingController();

  // final user = FirebaseAuth.instance.currentUser!;
  Future addEntryPage() async {
    if (_journeydate == "Tap to select date") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fill Journey Date",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }
    if (_bookingdate == "Tap to select date") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fill Booking Date",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }
    if (nameController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fill name",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }

    if (mode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Select Mode",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }

    if (fromcitycontroller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Select From City",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }

    if (tocitycontroller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Select to City",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }

    if (pickTime == "Time") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fill Time",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }

    if (amountController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fill amount",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }

    try {
      String amount = int.parse(amountController.text).toString();
      int rev = int.parse(amountController.text);

      FirebaseFirestore.instance.collection("jd").doc().set({
        'Amount': amount,
        'rev': rev,
        'Jorneydate': _pickedjourneydate,
        'Bookingdate': _pickedbookingdate,
        'Customername': nameController.text,
        // 'Customername': nameController.text,
        'Modeoftransport': mode,
        'Fromplace': fromcitycontroller.text,
        'Toplace': tocitycontroller.text,
        'Traveltime': pickTime,
        'Customeraddedby': kUserEmail,
      });

      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "New Entry Added",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          ModalRoute.withName('/'));
    } on Exception catch (e) {}
  }

  Stream<QuerySnapshot> getUsersStream() {
    return FirebaseFirestore.instance.collection('Customerslist').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyAppBar2(title: "Ticket Entry"),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Journey Date",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // date picker

              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.black26),
                        left: BorderSide(width: 1.0, color: Colors.black26),
                        right: BorderSide(width: 1.0, color: Colors.black26),
                        bottom: BorderSide(width: 1.0, color: Colors.black26),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          child: Text(_journeydate,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                          onTap: () {
                            _selectjourneyDate(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today,
                              color: Colors.black87, size: 18),
                          tooltip: 'Tap to open date picker',
                          onPressed: () {
                            _selectjourneyDate(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Booking Date",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // date picker

              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.black26),
                        left: BorderSide(width: 1.0, color: Colors.black26),
                        right: BorderSide(width: 1.0, color: Colors.black26),
                        bottom: BorderSide(width: 1.0, color: Colors.black26),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          child: Text(_bookingdate,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                          onTap: () {
                            _selectbookingDate(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today,
                              color: Colors.black87, size: 18),
                          tooltip: 'Tap to open date picker',
                          onPressed: () {
                            _selectbookingDate(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Customer Name",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              // MyTextField(
              //   controller: nameController,
              //   hintText: "Name",
              // ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              //   child: StreamBuilder<QuerySnapshot>(
              //     stream: FirebaseFirestore.instance
              //         .collection('Customerslist')
              //         .snapshots(),
              //     builder: (BuildContext context,
              //         AsyncSnapshot<QuerySnapshot> snapshot) {
              //       if (!snapshot.hasData) {
              //         return const Text('Loading...');
              //       }
              //       return DropdownButtonFormField<String>(
              //         decoration: InputDecoration(
              //           hintText: 'Name',
              //           contentPadding:
              //               const EdgeInsets.fromLTRB(12, 16, 0, 16),
              //           border: OutlineInputBorder(),
              //           enabledBorder: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black26),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black26),
              //           ),
              //           fillColor: Colors.white,
              //           filled: true,
              //         ),
              //         value: customername,
              //         onChanged: (String? value) {
              //           setState(() {
              //             customername = value;
              //           });
              //         },
              //         items: _customernames.map((String? value) {
              //           return DropdownMenuItem<String>(
              //             value: value,
              //             child: Text(value as String),
              //           );
              //         }).toList(),
              //       );
              //     },
              //   ),
              // ),

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "  Name",
                      // labelText: 'Country',
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    var countries = await FirebaseFirestore.instance
                        .collection('Customerslist')
                        .where('CustomerName', isGreaterThanOrEqualTo: pattern)
                        .where('CustomerName', isLessThan: pattern + 'z')
                        .get();
                    return countries.docs
                        .map((doc) => doc.data()['CustomerName'])
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    nameController.text = suggestion;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Mode of Transport",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('modeoftransport')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Mode of Transport',
                        contentPadding:
                            const EdgeInsets.fromLTRB(12, 16, 0, 16),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      value: mode,
                      onChanged: (String? value) {
                        setState(() {
                          mode = value;
                        });
                      },
                      items: _modeoftransport.map((String? value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value as String),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "From",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              //   child: StreamBuilder<QuerySnapshot>(
              //     stream: FirebaseFirestore.instance
              //         .collection('modeoftransport')
              //         .snapshots(),
              //     builder: (BuildContext context,
              //         AsyncSnapshot<QuerySnapshot> snapshot) {
              //       if (!snapshot.hasData) {
              //         return const Text('Loading...');
              //       }
              //       return DropdownButtonFormField<String>(
              //         decoration: InputDecoration(
              //           hintText: 'From',
              //           contentPadding:
              //               const EdgeInsets.fromLTRB(12, 16, 0, 16),
              //           border: OutlineInputBorder(),
              //           enabledBorder: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black26),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black26),
              //           ),
              //           fillColor: Colors.white,
              //           filled: true,
              //         ),
              //         value: fromcity,
              //         onChanged: (String? value) {
              //           setState(() {
              //             fromcity = value;
              //           });
              //         },
              //         items: _fromcities.map((String? value) {
              //           return DropdownMenuItem<String>(
              //             value: value,
              //             child: Text(value as String),
              //           );
              //         }).toList(),
              //       );
              //     },
              //   ),
              // ),
              ///
              ///
              ///
              ///

              ///

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: fromcitycontroller,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: " City",
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
                    fromcitycontroller.text = suggestion;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "to",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              //   child: StreamBuilder<QuerySnapshot>(
              //     stream: FirebaseFirestore.instance
              //         .collection('modeoftransport')
              //         .snapshots(),
              //     builder: (BuildContext context,
              //         AsyncSnapshot<QuerySnapshot> snapshot) {
              //       if (!snapshot.hasData) {
              //         return const Text('Loading...');
              //       }
              //       return DropdownButtonFormField<String>(
              //         decoration: InputDecoration(
              //           hintText: 'to',
              //           contentPadding:
              //               const EdgeInsets.fromLTRB(12, 16, 0, 16),
              //           border: OutlineInputBorder(),
              //           enabledBorder: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black26),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black26),
              //           ),
              //           fillColor: Colors.white,
              //           filled: true,
              //         ),
              //         value: tocity,
              //         onChanged: (String? value) {
              //           setState(() {
              //             tocity = value;
              //           });
              //         },
              //         items: _tocities.map((String? value) {
              //           return DropdownMenuItem<String>(
              //             value: value,
              //             child: Text(value as String),
              //           );
              //         }).toList(),
              //       );
              //     },
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: tocitycontroller,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: " City",
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
                    tocitycontroller.text = suggestion;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Time",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // time picker

              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.black26),
                        left: BorderSide(width: 1.0, color: Colors.black26),
                        right: BorderSide(width: 1.0, color: Colors.black26),
                        bottom: BorderSide(width: 1.0, color: Colors.black26),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          child: Text(pickTime,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                          onTap: () async {
                            _selecttime(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.access_time_sharp,
                              color: Colors.black87, size: 18),
                          tooltip: 'Tap to open date picker',
                          onPressed: () {
                            _selecttime(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Amount",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              AmountTextfield(
                controller: amountController,
              ),
              
              MyButton1(
                colored: Colors.amber.shade100,
                title: "Submit",
                ontapp: () {
                  (pickTime == "Time" &&
                          nameController.text == "" &&
                          amountController.text == "" &&
                          fromcitycontroller.text == "" &&
                          tocitycontroller.text == "" &&
                          pickTime == "Time" &&
                          _journeydate == "Tap to select date" &&
                          _bookingdate == "Tap to select date")
                      ? ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Fill all the Fields",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        )
                      : addEntryPage();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Column(
//             children: [
//               Text(_selectedDate == null
//                   ? 'No date selected'
//                   : _selectedDate.toString()),
//               ElevatedButton(
//                 onPressed: () => _selectDate(context),
//                 child: Text('Select date'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   final CollectionReference collection =
//                       FirebaseFirestore.instance.collection('my_collection');
//                   await collection.add({
//                     'selected_date': Timestamp.fromDate(_selectedDate),
//                   });
//                 },
//                 child: Text('Save to Firebase'),
//               ),
//             ],
//           )
