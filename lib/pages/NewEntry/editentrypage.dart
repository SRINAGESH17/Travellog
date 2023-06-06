// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/downloadbox.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/CustomerList/customerlist.dart';

import '../../services/autoCompleteSearch.dart';

class EditEntryPage extends StatefulWidget {
  final String docid;
  const EditEntryPage({super.key, required this.docid});

  @override
  State<EditEntryPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditEntryPage> {
  final amountController = TextEditingController();
  final nameController = TextEditingController();
  final reffController = TextEditingController();

  DateTime jdate = DateTime.now();
  DateTime bdate = DateTime.now();

  String _journeydate = 'Tap to select date';
  DateTime _pickedjourneydate = DateTime.now();

  Future<void> _selectjourneyDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (d != null)
      setState(() {
        _journeydate = new DateFormat.yMMMMd("en_US").format(d);
        jdate = d;
        _pickedbookingdate = d;
      });
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
    if (d != null)
      // ignore: curly_braces_in_flow_control_structures
      setState(() {
        _bookingdate = new DateFormat.yMMMMd("en_US").format(d);
        bdate = d;
        _pickedbookingdate = d;
      });
  }

  // var pickTime = 'Time';
  // Future<void> _selecttime(BuildContext context) async {
  //   TimeOfDay? pickedTime = await showTimePicker(
  //     initialTime: TimeOfDay.now(),
  //     context: context, //context of current state
  //   );

  //   if (pickedTime != null) {
  //     print(pickedTime.format(context)); //output 10:51 PM
  //     DateTime parsedTime =
  //         DateFormat.jm().parse(pickedTime.format(context).toString());
  //     //converting to DateTime so that we can further format on different pattern.
  //     print(parsedTime); //output 1970-01-01 22:53:00.000
  //     String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
  //     print(formattedTime);
  //     setState(() {
  //       pickTime = formattedTime as String;
  //     }); //output 14:59:00
  //     //DateFormat() is from intl package, you can format the time on any pattern you need.
  //   } else {
  //     print("Time is not selected");
  //   }
  // }

  String? customername;
  List<String> _customernames = [];
  String? mode;
  List<String> _modeoftransport = [];
  String? fromcity;
  List<String> _fromcities = [];
  String? tocity;
  List<String> _tocities = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController editnamecontroller = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void _getDocumentData() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('jd')
        .doc(widget.docid)
        .get();
    final data = documentSnapshot.data();
    if (data != null) {
      setState(() {
        jdate = data['Jorneydate'].toDate();
        _journeydate = data['Jorneydate'].toString();
        bdate = data['Bookingdate'].toDate();
        _bookingdate = data['Bookingdate'].toString();
        pickTimeUi = data['Traveltime'];
        log(pickTimeUi.toString());
        pdfurl = data["ticketDoc"];
        pdfurl2 = data["ticketDoc2"];
        _playerValue = data['TypeOFGuest'];

        // pickTimeUi = DateFormat('HH:mm').format(pickTime!);
      });
    }
  }

  DateTime? pickTime;
  String pickTimeUi = 'Time';

  Future<void> _selecttime(BuildContext context) async {
    TimeOfDay? timeOfDay = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context, //context of current state
    );
    log(timeOfDay.toString());
    if (timeOfDay != null) {
      pickTime = DateTime(
        jdate.year,
        jdate.month,
        jdate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      log("PickedTime: ${pickTime.toString()}");
      setState(() {
        pickTimeUi = DateFormat('HH:mm').format(pickTime!);
      });
      updateJourneyDate(); //output 14:59:00
    } else {
      log("Time is not selected");
    }
  }

  DateTime updateJourneyDate() {
    DateTime updatedJourneyDate = DateTime(
      jdate.year,
      jdate.month,
      jdate.day,
      pickTime!.hour,
      pickTime!.minute,
    );
    log("Updated Journey Date: ${updatedJourneyDate.toString()}");
    setState(() {
      jdate = updatedJourneyDate;
    });
    return updatedJourneyDate;
  }

  @override
  void initState() {
    super.initState();
    _getDocumentData();

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
  }

  final fromcitycontroller = TextEditingController();
  final tocitycontroller = TextEditingController();

  final user = FirebaseAuth.instance.currentUser!;

  List<String> _existingNames = [];

  AutoCompleteSearch autoCompleteSearch = AutoCompleteSearch();

  Future updateentry() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      int rev = int.parse(amountController.text);
      String amount = int.parse(amountController.text).toString();

      await FirebaseFirestore.instance
          .collection("jd")
          .doc(widget.docid)
          .update({
        'Traveltime': pickTimeUi,
        'Customername': editnamecontroller.text,
        'Amount': amount,
        'rev': rev,
        'Jorneydate': jdate,
        'Bookingdate': bdate,
        'Modeoftransport': mode,
        'Fromplace': fromcitycontroller.text,
        'Toplace': tocitycontroller.text,
        'Traveltime': pickTimeUi,
        'ticketDoc': "",
      });

      Navigator.of(context).pop();

      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "Entry Updated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.of(context).pop();
    } on Exception catch (e) {
      Navigator.pop(context);
    }
  }

  Future updateentry2(String? pdfurl, String? pdfurl2) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      int rev = int.parse(amountController.text);
      String amount = int.parse(amountController.text).toString();

      await FirebaseFirestore.instance
          .collection("jd")
          .doc(widget.docid)
          .update({
        'Traveltime': pickTime,
        'Amount': amount,
        'rev': rev,
        'Jorneydate': jdate,
        'Bookingdate': bdate,
        'Customername': editnamecontroller.text,
        'Modeoftransport': mode,
        'Fromplace': fromcitycontroller.text,
        'Toplace': tocitycontroller.text,
        'Traveltime': pickTimeUi,
        'ticketDoc': pdfurl,
        'ticketDoc2': pdfurl2,
        'TypeOFGuest': _playerValue,
        'Reference': reffController.text
      });

      Navigator.of(context).pop();

      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "Entry Updated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.of(context).pop();
    } on Exception catch (e) {
      Navigator.pop(context);
    }
  }

  Stream<QuerySnapshot> getUsersStream() {
    return FirebaseFirestore.instance.collection('Customerslist').snapshots();
  }

  File? _pdfFile;
  String pdfurl = "";

  String filename = "";

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        filename = File(_pdfFile!.path).path.split('/').last;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<String?> _uploadPDF() async {
    if (_pdfFile != null) {
      // Create a reference to the location in Firebase Storage where you want to store the file
      Reference storageReference =
          FirebaseStorage.instance.ref().child('pdfs/${(_pdfFile!.path)}');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(_pdfFile!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded file
      String downloadUrl = await storageReference.getDownloadURL();

      // Print the download URL (for testing purposes)
      print('Download URL: $downloadUrl');
      setState(() {
        pdfurl = downloadUrl;
      });
    } else {
      // No PDF file is picked
    }
    return pdfurl;
  }

  File? _pdfFile2;
  String pdfurl2 = "";

  String filename2 = "";

  Future<void> _pickPDF2() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile2 = File(result.files.single.path!);
        filename2 = File(_pdfFile2!.path).path.split('/').last;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<String?> _uploadPDF2() async {
    if (_pdfFile2 != null) {
      // Create a reference to the location in Firebase Storage where you want to store the file
      Reference storageReference =
          FirebaseStorage.instance.ref().child('pdfs/${(_pdfFile2!.path)}');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(_pdfFile2!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded file
      String downloadUrl = await storageReference.getDownloadURL();

      // Print the download URL (for testing purposes)
      print('Download URL: $downloadUrl');
      setState(() {
        pdfurl2 = downloadUrl;
      });
    } else {
      // No PDF file is picked
    }
    return pdfurl2;
  }

  void _deletepdf1() {
    setState(() {
      _pdfFile = null;
      pdfurl = "";
      filename = "";
    });
  }

  void _deletepdf2() {
    setState(() {
      _pdfFile2 = null;
      pdfurl2 = "";
      filename2 = "";
    });
  }

  String _playerValue = 'Player';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            MyAppBar2(
              title: "Edit Ticket Entry",
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("jd")
                    .doc(widget.docid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map data = snapshot.data?.data() as Map<String, dynamic>;

                    fromcitycontroller.text = data['Fromplace'];
                    tocitycontroller.text = data['Toplace'];
                    amountController.text = data['Amount'];
                    editnamecontroller.text = data['Customername'];
                    mode = data['Modeoftransport'];
                    fromcity = data['Fromplace'];
                    tocity = data['Toplace'];
                    reffController.text = data['Reference'];

                    return Column(
                      children: [
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
                                  top: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  left: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  right: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  bottom: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(26, 0, 5, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  InkWell(
                                    child: Text(
                                        '${bdate.day}/${bdate.month}/${bdate.year}',
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
                                  top: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  left: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  right: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  bottom: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(26, 0, 5, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  InkWell(
                                    child: Text(
                                        '${jdate.day}/${jdate.month}/${jdate.year}',
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
                            "Name",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          child: TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: editnamecontroller,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: "  Name",
                                // labelText: 'Country',
                                fillColor: Colors.white,
                                focusColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              return autoCompleteSearch
                                  .getCustomerSuggestions(pattern.trim());
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              editnamecontroller.text =
                                  suggestion.toLowerCase();
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
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
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
                                  .where('name',
                                      isGreaterThanOrEqualTo: pattern)
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
                                  .where('name',
                                      isGreaterThanOrEqualTo: pattern)
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
                                  top: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  left: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  right: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                  bottom: BorderSide(
                                      width: 1.0, color: Colors.black26),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(26, 0, 5, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  InkWell(
                                    child: Text(pickTimeUi,
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
                        Row(
                          children: [
                            Flexible(
                              child: AmountTextfield(
                                controller: amountController,
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                          child: Text(
                            "Reference",
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                        ),
                        MyTextField(
                          controller: reffController,
                          hintText: "Reference",
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                          child: Text(
                            "Type of Guest",
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Radio(
                                    value: 'Player',
                                    groupValue: _playerValue,
                                    onChanged: (value) {
                                      setState(() {
                                        _playerValue = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Player',
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Radio(
                                    value: 'Guest',
                                    groupValue: _playerValue,
                                    onChanged: (value) {
                                      setState(() {
                                        _playerValue = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Guest',
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        //

                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 15, 30, 5),
                          child: Container(
                              width: 355,
                              height: MediaQuery.of(context).size.height * .10,
                              decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 35,
                                    ),
                                    SizedBox(width: 16),
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Pdf 1",
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          StreamBuilder<Object>(
                                            stream: FirebaseFirestore.instance
                                                .collection("jd")
                                                .doc(widget.docid)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (_pdfFile == null &&
                                                  data["ticketDoc"] == "") {
                                                return PdfAbut(ontapp: () {
                                                  _pickPDF();
                                                });
                                              }
                                              return Row(
                                                children: [
                                                  ChangeBut(ontapp: () {
                                                    _pickPDF();
                                                  }),
                                                  SizedBox(width: 5),
                                                  DeteleBut(ontapp: () {
                                                    _deletepdf1();
                                                  })
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 5, 30, 15),
                          child: Container(
                              width: 355,
                              height: MediaQuery.of(context).size.height * .10,
                              decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 35,
                                    ),
                                    SizedBox(width: 16),
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Pdf 2",
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          StreamBuilder<Object>(
                                            stream: FirebaseFirestore.instance
                                                .collection("jd")
                                                .doc(widget.docid)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (_pdfFile2 == null &&
                                                  data["ticketDoc2"] == "") {
                                                return PdfAbut(ontapp: () {
                                                  _pickPDF2();
                                                });
                                              }
                                              return Row(
                                                children: [
                                                  ChangeBut(ontapp: () {
                                                    _pickPDF2();
                                                  }),
                                                  SizedBox(width: 5),
                                                  DeteleBut(ontapp: () {
                                                    _deletepdf2();
                                                  })
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Flexible(
                        //       child: MyButton4(
                        //           title: "Change Doc",
                        //           colored: Colors.deepPurple.shade200,
                        //           ontapp: () {
                        //             _pickPDF();
                        //           }),
                        //     ),
                        //     Flexible(
                        //       child: MyButton4(
                        //           title: "Change Doc 2",
                        //           colored: Colors.deepPurple.shade200,
                        //           ontapp: () {
                        //             _pickPDF2();
                        //           }),
                        //     ),
                        //   ],
                        // ),

                        if (_pdfFile != null)
                          Center(
                            child: Text("Pdf 1 is $filename"),
                          ),

                        if (_pdfFile2 != null)
                          Center(
                            child: Text("Pdf 2 is $filename2"),
                          ),

                        MyButton1(
                          colored: Colors.amber.shade100,
                          title: "Update",
                          ontapp: () async {
                            if (_pdfFile != null) {
                              final pdfurl = await _uploadPDF();
                            }
                            if (_pdfFile2 != null) {
                              final pdfurl2 = await _uploadPDF2();
                            }
                            updateentry2(pdfurl, pdfurl2);
                          },
                        )
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })
          ],
        ),
      )),
    );
  }
}
