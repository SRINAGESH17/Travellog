import 'dart:convert';
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
import 'package:path/path.dart' as path;
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/datepicker.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:intl/intl.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:http/http.dart';
import 'package:travellog/pages/homepage.dart';
import 'package:travellog/services/autoCompleteSearch.dart';
import 'package:travellog/utils.dart';

class NewEntry extends StatefulWidget {
  const NewEntry({super.key, this.customerName});
  final String? customerName;
  @override
  State<NewEntry> createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {
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

  /* ----------------------- Storing CustomerNames here ----------------------- */

  List<String> _existingNames = [];

  AutoCompleteSearch autoCompleteSearch = AutoCompleteSearch();

  String _journeydate = 'Tap to select date';
  DateTime _pickedjourneydate = DateTime.now();

  String? _journeymonth;

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
        _journeymonth = DateFormat('MMMM').format(d);
        _pickedjourneydate = d;
        if (pickTime != null) {
          updateJourneyDate();
        }
        log(_pickedjourneydate.toString());
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

//  var pickTime = 'Time';
//   TimeOfDay _time = TimeOfDay.now();

//   Future<void> _selecttime(BuildContext context) async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       initialTime: TimeOfDay.now(),
//       context: context, //context of current state
//     );

//     if (pickedTime != null) {
//       print(pickedTime.format(context)); //output 10:51 PM
//       DateTime parsedTime =
//           DateFormat.jm().parse(pickedTime.format(context).toString());
//       //converting to DateTime so that we can further format on different pattern.
//       print(parsedTime); //output 1970-01-01 22:53:00.000
//       String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
//       print(formattedTime);
//       setState(() {
//         pickTime = formattedTime as String;
//       }); //output 14:59:00
//       //DateFormat() is from intl package, you can format the time on any pattern you need.
//     } else {
//       print("Time is not selected");
//     }
//   }

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
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
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
      _pickedjourneydate.year,
      _pickedjourneydate.month,
      _pickedjourneydate.day,
      pickTime!.hour,
      pickTime!.minute,
    );
    log("Updated Journey Date: ${updatedJourneyDate.toString()}");
    setState(() {
      _pickedjourneydate = updatedJourneyDate;
    });
    return updatedJourneyDate;
  }

  /* ------------------------ Capitalize Customer Names ----------------------- */

  String capitalizeFirstLetter(String input) {
    List<String> words = input.split(' ');
    List<String> capitalizedWords = words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .toList();
    return capitalizedWords.join(' ');
  }

  String? mode = "Flight";
  List<String> _modeoftransport = [];
  String? fromcity;
  List<String> _fromcities = [];
  String? tocity;
  List<String> _tocities = [];
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  DateTime _creadeddate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _bookingdate = DateFormat.yMMMMd("en_US").format(DateTime.now());
    _pickedbookingdate = DateTime.now();

    nameController.text = widget.customerName ?? "";

    FirebaseFirestore.instance
        .collection('Customerslist')
        .get()
        .then((snapshot) {
      List<String> names = [];
      snapshot.docs.forEach((doc) {
        names.add(doc.data()['CustomerName'].toLowerCase());
      });
      names.sort((a, b) => a.compareTo(b));
      // log(names.toString());
      setState(() {
        _existingNames = names;
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
      log(modes[0]);
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
  final reffController = TextEditingController(text: '');

  final user = FirebaseAuth.instance.currentUser!;
  Future<List> getAdminToken() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("FcmToken")
        .where("email", isEqualTo: 'admin@gmail.com')
        .get();
    return snapshot.docs.first.get('fcmTokens');
  }

  String capitalizeWords(String input) {
    return input
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Future<void> sendNotification(Map<String, String> data) async {
    var token = await getAdminToken();

    var response = await post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key='
            'AAAAo68SOsw:APA91bFDv5sSA0iCm2U4rAQa9yWEDTN-WHBYzilgrZ1f1TFStNJSSLxvupOtEXg-CD2_JCkgV2k5t_6qUHrrHh_hcsYdstQFWGsnqO02qu-exCwoSaZPIJjLiSbycZE8MjU--gcHxkWG',
      },
      body: json.encode({
        'notification': {
          'body': '${data['fromCity']} to ${data['toCity']}',
          'title': '${data['name']} ${data['journeyDate']} ${data['time']}'
        },
        'data': {'message': data},
        'registration_ids': token,
      }),
    );
    print(response.body);
  }

  Future addnewentry() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    if (_journeydate == "Tap to select date") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Fill Journey Date",
            style: TextStyle(
              color: Colors.red,
            ),
            textScaleFactor: 1.0,
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }
    if (_bookingdate == "Tap to select date") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Fill Booking Date",
            style: TextStyle(
              color: Colors.red,
            ),
            textScaleFactor: 1.0,
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }
    if (nameController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
        const SnackBar(
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
        const SnackBar(
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
        const SnackBar(
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

    if (pickTimeUi == "Time") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
        const SnackBar(
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
      DateTime now = DateTime.now();
      String currentMonth = DateFormat('MMMM').format(now);
      int currentYear = now.year;
      String amount = int.parse(amountController.text).toString();
      int rev = int.parse(amountController.text);

      /* -------------------- Checking If Customer Names Exist -------------------- */

      if (!_existingNames.contains(nameController.text.toLowerCase())) {
        await CustomerServices.addCustomerName(name: nameController.text);
      }

      /* ------------------------ Storing Data to Firebase ------------------------ */

      FirebaseFirestore.instance.collection("jd").doc().set({
        'Amount': amount,
        'rev': rev,
        'month': _journeymonth,
        'year': currentYear,
        'createdAt': _creadeddate,
        'Jorneydate': _pickedjourneydate,
        'Bookingdate': _pickedbookingdate,
        'Customername': nameController.text,
        // 'Customername': nameController.text,
        'Modeoftransport': mode,
        'Fromplace': fromcitycontroller.text,
        'ticketDoc': "",
        'Toplace': tocitycontroller.text,
        'Traveltime': pickTime,
        'Reference': reffController.text,
        'TypeOFGuest': _playerValue,
        'Customeraddedby': user.email! as String,
      });

      Map<String, String> data = {
        'name': capitalizeWords(nameController.text),
        'fromCity': fromcitycontroller.text,
        'toCity': tocitycontroller.text,
        'journeyDate': DateFormat('dd/MM/yy').format(_pickedjourneydate),
        'time': pickTimeUi,
      };

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
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()),
          ModalRoute.withName('/'));
    } on Exception {
      Navigator.pop(context);
    }
  }

  Future addnewentry2(String? pdfurl, String? pdfur2) async {
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return const Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   },
    // );
    await Future.delayed(Duration(seconds: 5));
    if (_journeydate == "Tap to select date") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Fill Journey Date",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }
    if (_bookingdate == "Tap to select date") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Fill Booking Date",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }
    if (nameController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Fill name",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }

    if (mode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select Mode",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }

    if (fromcitycontroller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select From City",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }

    if (tocitycontroller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select to City",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }

    if (pickTimeUi == "Time") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Fill Time",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }

    if (amountController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Fill amount",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigator.pop(context);
      return null;
    }

    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Upload Doc 1",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
      return null;
    }

    try {
      DateTime now = DateTime.now();
      String currentMonth = DateFormat('MMMM').format(now);
      int currentYear = now.year;
      String amount = int.parse(amountController.text).toString();
      int rev = int.parse(amountController.text);

      /* -------------------- Checking If Customer Names Exist -------------------- */

      if (!_existingNames.contains(nameController.text.toLowerCase())) {
        await CustomerServices.addCustomerName(name: nameController.text);
      }

      /* ------------------------ Storing Data to Firebase ------------------------ */

      FirebaseFirestore.instance.collection("jd").doc().set({
        'Amount': amount,
        'rev': rev,
        'month': _journeymonth,
        'ticketDoc': pdfurl,
        'ticketDoc2': pdfurl2,
        'year': currentYear,
        'createdAt': _creadeddate,
        'Jorneydate': _pickedjourneydate,
        'Bookingdate': _pickedbookingdate,
        'Customername': nameController.text,
        // 'Customername': nameController.text,
        'Modeoftransport': mode,
        'Fromplace': fromcitycontroller.text,
        'Toplace': tocitycontroller.text,
        'Reference': reffController.text,
        'Traveltime': pickTimeUi,
        'TypeOFGuest': _playerValue,
        'time':
            "", // need to store the travel time as timestamp EXAMPLE 11.00 as timestmap

        'Customeraddedby': user.email! as String,
      });
      Map<String, String> data = {
        'mode': _playerValue,
        'name': capitalizeWords(nameController.text),
        'fromCity': fromcitycontroller.text,
        'toCity': tocitycontroller.text,
        'journeyDate': DateFormat('dd/MM/yy').format(_pickedjourneydate),
        'time': pickTimeUi,
      };

      sendNotification(data);

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
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()),
          ModalRoute.withName('/'));
    } on Exception {
      // Navigator.pop(context);
    }
  }

  Stream<QuerySnapshot> getUsersStream() {
    return FirebaseFirestore.instance.collection('Customerslist').snapshots();
  }

  // vpdf 1
  String filename = "";
  File? _pdfFile;
  String? pdfurl;

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
          FirebaseStorage.instance.ref().child('pdfs/${(_pdfFile!)}');

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

  // vpdf 2

  String filename2 = "";
  File? _pdfFile2;
  String pdfurl2 = "";

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
          FirebaseStorage.instance.ref().child('pdfs/${(_pdfFile2!)}');

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

  String _playerValue = "Player";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyAppBar2(title: "Ticket Entry"),

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Booking Date",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  textScaleFactor: 1.0,
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
                          icon: const Icon(Icons.calendar_today,
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
                  textScaleFactor: 1.0,
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
                          icon: const Icon(Icons.calendar_today,
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

              /* --------------------------- Customer Name Field -------------------------- */

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Customer Name",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  textScaleFactor: 1.0,
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
                  itemBuilder: (itemcontext, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion,
                        textScaleFactor: 1.0,
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    nameController.text = capitalizeFirstLetter(suggestion);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                child: Text(
                  "Mode of Transport",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  textScaleFactor: 1.0,
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('modeoftransport')
                      .snapshots(),
                  builder: (BuildContext transportcontext,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Mode of Transport',
                        contentPadding: EdgeInsets.fromLTRB(12, 16, 0, 16),
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
                  textScaleFactor: 1.0,
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
                    decoration: const InputDecoration(
                      hintText: " City",
                      // labelText: 'Country',
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return autoCompleteSearch
                        .getCitySuggestions(pattern.trim());
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
                  textScaleFactor: 1.0,
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
                    decoration: const InputDecoration(
                      hintText: " City",
                      // labelText: 'Country',
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return autoCompleteSearch
                        .getCitySuggestions(pattern.trim());
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
                  textScaleFactor: 1.0,
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
                          icon: const Icon(Icons.access_time_sharp,
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
                  textScaleFactor: 1.0,
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
                      fontSize: 16, fontWeight: FontWeight.w500),
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
                      fontSize: 16, fontWeight: FontWeight.w500),
                  textScaleFactor: 1.0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      const Text(
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
                      const Text(
                        'Guest',
                        textScaleFactor: 1.0,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        value: 'Cancel',
                        groupValue: _playerValue,
                        onChanged: (value) {
                          setState(() {
                            _playerValue = value!;
                          });
                        },
                      ),
                      const Text(
                        'Cancel',
                        textScaleFactor: 1.0,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: MyButton4(
                        title: "Upload Doc 1",
                        colored: Colors.deepPurple.shade200,
                        ontapp: () {
                          _pickPDF();
                        }),
                  ),
                  Flexible(
                    child: MyButton4(
                        title: "Upload Doc 2",
                        colored: Colors.deepPurple.shade200,
                        ontapp: () {
                          _pickPDF2();
                        }),
                  ),
                ],
              ),

              if (_pdfFile != null)
                Center(
                  child: Text("Pdf 1 is $filename"),
                ),

              if (_pdfFile2 != null)
                Center(
                  child: Text("Pdf 2 is $filename2"),
                ),

              /* ------------------------------ Submit Button ----------------------------- */

              MyButton1(
                colored: Colors.amber.shade100,
                title: "Submit",
                ontapp: () async {
                  // (pickTime == "Time" &&
                  //         nameController.text == "" &&
                  //         amountController.text == "" &&
                  //         fromcitycontroller.text == "" &&
                  //         tocitycontroller.text == "" &&
                  //         pickTime == "Time" &&
                  //         _journeydate == "Tap to select date" &&
                  //         _bookingdate == "Tap to select date")
                  //     ? ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           content: Text(
                  //             "Fill all the Fields",
                  //             style: TextStyle(
                  //               color: Colors.red,
                  //             ),
                  //           ),
                  //           duration: Duration(seconds: 3),
                  //         ),
                  //       )
                  //     : addnewentry();
                  // if (_pdfFile2 == null) {
                  //   addnewentry();
                  // } else {
                  //   final pdfurl2 = await _uploadPDF2();
                  //   addnewentry2(pdfurl2);
                  // }
                  Utils(context).startLoading();
                  final pdfurl = await _uploadPDF();
                  if (_pdfFile2 != null) final pdfurl2 = await _uploadPDF2();
                  await addnewentry2(pdfurl, pdfurl2);
                  Utils(context).stopLoading();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerServices {
  static CollectionReference customerReference =
      FirebaseFirestore.instance.collection('Customerslist');

  static Future<void> addCustomerName({String? name}) async {
    try {
      await customerReference.add({
        'CustomerDoc': "",
        'CustomerName': name,
        'CustomerNumber': "",
        'Customercity': "",
        'docId': "",
        'isCustomer': "",
      }).then((value) => FirebaseFirestore.instance
              .collection("Customerslist")
              .doc(value.id)
              .update({
            'docId': value.id,
          }));
    } catch (e) {
      log(e.toString());
    }
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