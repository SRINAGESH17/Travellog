import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/downloadbox.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/CustomerList/customerlist.dart';

class EditCustomerPage extends StatefulWidget {
  final String docid;
  const EditCustomerPage({super.key, required this.docid});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  String url = "";
  final CusNameController = TextEditingController();
  final CusNumberContoller = TextEditingController();
  late var CusCityController = TextEditingController();

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

    return url;
  }

  Future updateCustomer(String? url) async {
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

      FirebaseFirestore.instance
          .collection("Customerslist")
          .doc(widget.docid)
          .update({
        'CustomerName': CusNameController.text,
        'CustomerNumber': CusNumberContoller.text,
        'Customercity': CusCityController.text,
        'CustomerDoc': url,
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CustomerList()),
          ModalRoute.withName('/'));

      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "Customer Updated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    } on Exception catch (e) {
      Navigator.pop(context);
    }
  }

  Future updateCustomer2() async {
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

      FirebaseFirestore.instance
          .collection("Customerslist")
          .doc(widget.docid)
          .update({
        'CustomerName': CusNameController.text,
        'CustomerNumber': CusNumberContoller.text,
        'Customercity': CusCityController.text,
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CustomerList()),
          ModalRoute.withName('/'));

      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "Customer Updated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    } on Exception catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            MyAppBar2(
              title: "Edit Customer",
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("Customerslist")
                    .doc(widget.docid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    CusNameController.text = data['CustomerName'];
                    CusNumberContoller.text = data['CustomerNumber'];
                    CusCityController.text = data['Customercity'];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        MyTextField(
                          controller: CusCityController,
                          hintText: "City",
                        ),

                        (_imageFile == null)
                            ? Center(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              NetworkImage(data['CustomerDoc']),
                                          fit: BoxFit.contain)),
                                ),
                              )
                            : Container(
                                width: 500,
                                height: 500,
                                child: Center(child: Image.file(_imageFile!))),

                        UpdateBox(ontapp: () {
                          pickImage();
                        }),

                        SizedBox(height: 25),

                        MyButton1(
                          colored: Colors.amber.shade100,
                          title: "Update",
                          ontapp: () async {
                            if (_imageFile == null) {
                              updateCustomer2();
                            } else {
                              final url = await uploadImage();
                              updateCustomer(url);
                            }
                          },
                        ),
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
