import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travellog/auth/loginpage.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/downloadbox.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/CustomerList/addcustomerpage.dart';
import 'package:travellog/pages/CustomerList/editcustomerpage.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final CusNameController = TextEditingController();
  final CusNumberContoller = TextEditingController();
  late var CusCityController = TextEditingController();

  String? _selectedValue;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _getTotalDocuments();
    startTimer();

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

  int _totalDocuments = 0;

  Future _getTotalDocuments() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Customerslist").get();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: kIsAdmin ? MyButton2(
        title: "Add Customer",
        colored: Colors.blue.shade200,
        ontapp: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => AddCustomerPage(),
            ),
          );
        },
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            MyAppBar2(
              title: "Customer List",
            ),
            // Text("Total Customers are $_totalDocuments",
            //     style: GoogleFonts.poppins(
            //         fontSize: 21, fontWeight: FontWeight.w600)),
            Container(
                height: 60,
                width: 300,
                color: Colors.green.shade200,
                child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            '$_totalDocuments',
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 26,
                                fontWeight: FontWeight.w700),
                            textScaleFactor: 1.0,
                          ))),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Customerslist')
                      .orderBy('CustomerName', descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map((document) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                          child: Container(
                            width: 100,
                            height: MediaQuery.of(context).size.height * .13,
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
                                        document['CustomerName'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                        textScaleFactor: 1.0,
                                      ),
                                      Text(
                                        document['CustomerNumber'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                        textScaleFactor: 1.0,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        document['Customercity'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                        textScaleFactor: 1.0,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 5),
                                          StreamBuilder<Object>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Customerslist")
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (document["CustomerDoc"] ==
                                                    "") {
                                                  return Container();
                                                }
                                                return GestureDetector(
                                                  onTap: () {
                                                    showDialog<void>(
                                                      context: context,
                                                      barrierDismissible:
                                                          false, // user must tap button!
                                                      builder: (BuildContext
                                                          context) {
                                                        return Dialog(
                                                          child: Container(
                                                            width: 600,
                                                            height: 600,
                                                            decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                    image: NetworkImage(
                                                                        document[
                                                                            'CustomerDoc']),
                                                                    fit: BoxFit
                                                                        .contain)),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Icon(
                                                        Icons
                                                            .remove_red_eye_outlined,
                                                        size: 15),
                                                  ),
                                                );
                                              }),
                                          SizedBox(width: 5),
                                          Visibility(
                                            visible: kIsAdmin,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute<void>(
                                                    builder:
                                                        (BuildContext context) =>
                                                            EditCustomerPage(
                                                      docid: document['docId'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: Colors.green.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(5)),
                                                child: Icon(Icons.edit, size: 15),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Visibility(
                                            visible: kIsAdmin,
                                            child: GestureDetector(
                                              onTap: () async {
                                                showDialog<void>(
                                                  context: context,
                                                  barrierDismissible:
                                                      false, // user must tap button!
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      // <-- SEE HERE
                                                      title: const Text(
                                                          'Delete Customer'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ListBody(
                                                          children: const <
                                                              Widget>[
                                                            Text(
                                                                'Are you sure want to detele Customer?'),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text('No'),
                                                          onPressed: () {
                                                            Navigator.of(context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child:
                                                              const Text('Yes'),
                                                          onPressed: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Customerslist')
                                                                .doc(document.id)
                                                                .delete();
                                                            Navigator.of(context)
                                                                .pop();
                                                            await _getTotalDocuments();

                                                            Fluttertoast.showToast(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black54,
                                                                msg:
                                                                    "Customer Deleted",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .SNACKBAR,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                textColor:
                                                                    Colors.white,
                                                                fontSize: 16.0);
                                                            setState(() {});
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: Colors.green.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(5)),
                                                child:
                                                    Icon(Icons.delete, size: 15),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
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
