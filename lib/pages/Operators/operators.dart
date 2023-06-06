import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/Operators/addoperatorpage.dart';
import 'package:travellog/pages/Operators/editoperatorpage.dart';

class Operators extends StatelessWidget {
  const Operators({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MyButton2(
        title: "Add Operator",
        colored: Colors.pink.shade200,
        ontapp: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => AddOperator(),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            MyAppBar2(
              title: "Operators",
            ),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Operators')
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
                                        document['OperatorName'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                        textScaleFactor: 1.0,
                                      ),
                                      Text(
                                        document['OperatorMail'],
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
                                        document['OperatorPassword'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                        textScaleFactor: 1.0,
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              nameController.text =
                                                  document['OperatorName'];
                                              emailController.text =
                                                  document['OperatorMail'];
                                              passwordController.text =
                                                  document['OperatorPassword'];
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (BuildContext ctx) {
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 20,
                                                          left: 20,
                                                          right: 20,
                                                          bottom: MediaQuery.of(
                                                                      ctx)
                                                                  .viewInsets
                                                                  .bottom +
                                                              20),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    30,
                                                                    10,
                                                                    10,
                                                                    5),
                                                            child: Text(
                                                              "Name",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              textScaleFactor:
                                                                  1.0,
                                                            ),
                                                          ),
                                                          MyTextField(
                                                            controller:
                                                                nameController,
                                                            hintText: "Name",
                                                          ),

                                                          // email

                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    30,
                                                                    10,
                                                                    10,
                                                                    5),
                                                            child: Text(
                                                              "Email",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              textScaleFactor:
                                                                  1.0,
                                                            ),
                                                          ),
                                                          EmailTextfield(
                                                            controller:
                                                                emailController,
                                                          ),

                                                          // password

                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    30,
                                                                    10,
                                                                    10,
                                                                    5),
                                                            child: Text(
                                                              "Password",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                          PasswordTextfield(
                                                            controller:
                                                                passwordController,
                                                          ),
                                                          SizedBox(height: 25),

                                                          MyButton1(
                                                            colored: Colors
                                                                .amber.shade100,
                                                            title: "Update",
                                                            ontapp: () async {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "Operators")
                                                                  .doc(document
                                                                      .id)
                                                                  .update({
                                                                'OperatorMail':
                                                                    emailController
                                                                        .text,
                                                                'OperatorName':
                                                                    nameController
                                                                        .text,
                                                                'OperatorPassword':
                                                                    passwordController
                                                                        .text,
                                                                'isOperator':
                                                                    "1",
                                                              });

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              Fluttertoast.showToast(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black54,
                                                                  msg:
                                                                      " Operator Updated",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .SNACKBAR,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      16.0);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
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
                                          SizedBox(width: 15),
                                          GestureDetector(
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
                                                        'Delete Operator'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ListBody(
                                                        children: const <
                                                            Widget>[
                                                          Text(
                                                              'Are you sure want to detele operator?'),
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
                                                                  'Operators')
                                                              .doc(document.id)
                                                              .delete();

                                                          Navigator.of(context)
                                                              .pop();

                                                          Fluttertoast.showToast(
                                                              backgroundColor:
                                                                  Colors
                                                                      .black54,
                                                              msg:
                                                                  "Operator Deleted",
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
