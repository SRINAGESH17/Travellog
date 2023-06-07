import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/downloadbox.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/CustomerList/customerlist.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  String SelectedCity = "";
  String? url;
  final CusNameController = TextEditingController();
  final CusNumberContoller = TextEditingController();
  final CusCityController = TextEditingController();
  final _typeAheadController = TextEditingController();

  String? _selectedValue;
  List<String> _options = [];

  String picurl = "";

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection('citynames').get().then((snapshot) {
      List<String> options = [];
      snapshot.docs.forEach((doc) {
        options.add(doc.data()['name']);
      });
      setState(() {
        _options = options;
      });
    });
    ;
  }

  // download

  File? _imageFile;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future uploadImage() async {
    final reference =
        FirebaseStorage.instance.ref().child('images/${_imageFile!.path}');
    final uploadTask = reference.putFile(_imageFile!);

    await uploadTask.whenComplete(() => print('File uploaded'));

    final url = await reference.getDownloadURL();
    print('Download URL: $url');

    // Store download URL in Cloud Firestore
    setState(() {
      picurl = url;
    });
    return url;
  }

  bool isLoading = false;

  Future addCustomer(String? url) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      String number = int.parse(CusNumberContoller.text).toString();

      FirebaseFirestore.instance.collection("Customerslist").add({
        'CustomerName': CusNameController.text,
        'CustomerNumber': number,
        'Customercity': CusCityController.text,
        'isCustomer': "1",
        'CustomerDoc': url,
      }).then((value) => FirebaseFirestore.instance
              .collection("Customerslist")
              .doc(value.id)
              .update({
            'docId': value.id,
          }));

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CustomerList()),
          ModalRoute.withName('/'));
    } on Exception catch (e) {
      Navigator.pop(context);
    }
  }

  Future addCustomer2() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      String number = int.parse(CusNumberContoller.text).toString();

      FirebaseFirestore.instance.collection("Customerslist").add({
        'CustomerName': CusNameController.text,
        'CustomerNumber': number,
        'Customercity': CusCityController.text,
        'isCustomer': "1",
        'CustomerDoc': "",
      }).then((value) => FirebaseFirestore.instance
              .collection("Customerslist")
              .doc(value.id)
              .update({
            'docId': value.id,
          }));

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CustomerList()),
          ModalRoute.withName('/'));
    } on Exception catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    CusNameController.dispose();
    CusNumberContoller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyAppBar2(
            title: "Add Customer",
          ),

          // full name

          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
            child: Text(
              "Full Name",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
              textScaleFactor: 1.0,
            ),
          ),
          MyTextField(
            controller: CusNameController,
            hintText: "Name",
          ),

          // phone number

          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 10, 5),
            child: Text(
              "Phone Number",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
              textScaleFactor: 1.0,
            ),
          ),
          NumberTextfield(
            controller: CusNumberContoller,
          ),

          // city

          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 10, 5),
            child: Text(
              "City",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
              textScaleFactor: 1.0,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          //   child: TypeAheadFormField(
          //     textFieldConfiguration: TextFieldConfiguration(
          //       controller: _typeAheadController,
          //       decoration: InputDecoration(
          //         hintText: "  City",
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
          //       return countries.docs.map((doc) => doc.data()['name']).toList();
          //     },
          //     itemBuilder: (context, suggestion) {
          //       return ListTile(
          //         title: Text(suggestion),
          //       );
          //     },
          //     onSuggestionSelected: (suggestion) {
          //       _typeAheadController.text = suggestion;
          //     },
          //   ),
          // ),
          MyTextField(
            controller: CusCityController,
            hintText: "City",
          ),

          // Padding(
          //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          //   child: StreamBuilder<QuerySnapshot>(
          //     stream: FirebaseFirestore.instance
          //         .collection('citynames')
          //         .snapshots(),
          //     builder: (BuildContext context,
          //         AsyncSnapshot<QuerySnapshot> snapshot) {
          //       if (!snapshot.hasData) {
          //         return const Text('Loading...');
          //       }
          //       return DropdownButtonFormField<String>(
          //         decoration: InputDecoration(
          //           hintText: 'Select a city',
          //           contentPadding: const EdgeInsets.fromLTRB(12, 16, 0, 16),
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
          //         value: _selectedValue,
          //         onChanged: (String? value) {
          //           setState(() {
          //             _selectedValue = value;
          //           });
          //         },
          //         items: _options.map((String? value) {
          //           return DropdownMenuItem<String>(
          //             value: value,
          //             child: Text(value as String),
          //           );
          //         }).toList(),
          //       );
          //     },
          //   ),
          // ),

          //download box
          DownloadBox(
            ontapp: () {
              pickImage();
            },
          ),

          if (_imageFile != null) Image.file(_imageFile!),
          SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: pickImage,
          //   child: Text('Pick Image'),
          // ),
          // SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: _imageFile != null ? uploadImage : null,
          //   child: Text('Upload Image'),
          // ),

          //submit button
          MyButton1(
            colored: Colors.amber.shade100,
            title: "Submit",
            ontapp: () async {
              if (_imageFile == null) {
                addCustomer2();
              } else {
                final url = await uploadImage();
                addCustomer(url);
              }
            },
          )
        ],
      ),
    )));
  }
}
