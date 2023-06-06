import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:travellog/auth/loginpage.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/Settingss/Chngepasswrod.dart';
import 'package:travellog/pages/Settingss/filterDeleteScreen.dart';
import 'package:travellog/services/autoCompleteSearch.dart';

String globalCity = 'Goa';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCity();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    passwordController.text;
    super.dispose();
  }

  final origincontroller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser!;
  final passwordController = TextEditingController();
  @override
  List<String> existingNames = [];
  AutoCompleteSearch autoCompleteSearch = AutoCompleteSearch();

  Future<void> deleteAllDocumentsInCollection(
      String collectionPath, String pathname) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: Text('Delete $pathname'),
          content: const SingleChildScrollView(
            child: Text('Are you sure want to Delete ?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Enter Password'),
                      content: TextField(
                        controller: passwordController,
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Continue'),
                          onPressed: () async {
                            final passSnap = await FirebaseFirestore.instance
                                .collection('admin')
                                .get();
                            final password = passSnap.docs.first['password'];
                            if (password == null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Something went wrong',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            }
                            if (passwordController.text == password) {
                              final collectionReference = FirebaseFirestore
                                  .instance
                                  .collection(collectionPath);

                              final querySnapshot =
                                  await collectionReference.get();

                              for (final documentSnapshot
                                  in querySnapshot.docs) {
                                await documentSnapshot.reference.delete();
                              }
                              Fluttertoast.showToast(
                                  backgroundColor: Colors.black54,
                                  msg: "$pathname Deleted",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              if (mounted) Navigator.pop(context);
                              setState(() {
                                passwordController.clear();
                              });
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Incorrect Password',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  var cityList = [];
  var originList = [];
  bool cityLoading = true;

  loadCity() async {
    cityList = [];
    var result = await FirebaseFirestore.instance.collection('citynames').get();
    for (var data in result.docs) {
      cityList.add(data['name']);
    }
    originList = [];
    result = await FirebaseFirestore.instance.collection('OriginCities').get();
    for (var data in result.docs.first.get('cities')) {
      originList.add(data);
    }
    if (mounted) {
      setState(() {
        cityLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyAppBar2(title: "Settings"),
          (user.email == "admin@gmail.com")
              ? Column(
                  children: [
                    MyButton1(
                        title: "Delete Journey Details",
                        colored: Colors.orange.shade200,
                        ontapp: () async {
                          deleteAllDocumentsInCollection(
                              "jd", "Journey Details");
                        }),
                    MyButton1(
                        title: "Delete Filtered Journey Details",
                        colored: Colors.orange.shade200,
                        ontapp: () async {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return FilterDeleteScreen();
                            },
                          ));
                        }),
                    MyButton1(
                        title: "Delete Customer Data",
                        colored: Colors.orange.shade200,
                        ontapp: () async {
                          deleteAllDocumentsInCollection(
                              "Customerslist", "Customer Data");
                        }),
                    MyButton1(
                        title: "Change Admin Password",
                        colored: Colors.red.shade200,
                        ontapp: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => CPasswordPage(
                                docid: '0rt1hkiKh5UUZsEpKBoM',
                              ),
                            ),
                          );
                        }),
                    // MyButton1(
                    //     title: "add new field",
                    //     colored: Colors.orange.shade200,
                    //     ontapp: () async {
                    //       FirebaseFirestore.instance
                    //           .collection('jd')
                    //           .get()
                    //           .then((querySnapshot) {
                    //         querySnapshot.docs.forEach((doc) {
                    //           FirebaseFirestore.instance
                    //               .collection('jd')
                    //               .doc(doc.id)
                    //               .update({'ticketDoc2': ''});
                    //         });
                    //       });
                    //     }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 20, 45, 20),
                      child: Text(
                        "Select your orgin : ",
                        style: GoogleFonts.poppins(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    cityLoading
                        ? CircularProgressIndicator()
                        : Padding(
                            padding: EdgeInsets.all(20),
                            child: MultiSelectDialogField<dynamic>(
                              chipDisplay: MultiSelectChipDisplay(
                                textStyle: TextStyle(color: Colors.black),
                                chipColor: Colors.green.shade100,
                              ),
                              separateSelectedItems: true,
                              dialogHeight: 400,
                              onConfirm: (values) async {
                                var result = await FirebaseFirestore.instance
                                    .collection('OriginCities')
                                    .get();
                                result.docs.first.reference
                                    .update({'cities': values});
                              },
                              searchable: true,
                              items: [
                                ...cityList.map((e) => MultiSelectItem(e, e!))
                              ],
                              initialValue: originList,
                            ),
                          ),
                  ],
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.fromLTRB(155, 30, 0, 0),
            child: logoutButton(),
          )
        ],
      )),
    );
  }
}
