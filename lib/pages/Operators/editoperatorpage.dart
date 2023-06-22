import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/Operators/operators.dart';

final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController emailController = TextEditingController();

Future<void> updateFirestore(String docref) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Update data in Firestore
    await FirebaseFirestore.instance
        .collection("Operators")
        .doc(docref)
        .update({
      'OperatorMail': emailController.text,
      'OperatorName': nameController.text,
      'OperatorPassword': passwordController.text,
    });

    // Update password in Firebase Authentication
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   await user.updatePassword(passwordController.text);
    // }
  } catch (e) {
    // Error message
    print('Error updating data in Firestore: $e');
  }
}

class EditOperatorPage extends StatefulWidget {
  final String docref;

  const EditOperatorPage({
    super.key,
    required this.docref,
  });

  @override
  State<EditOperatorPage> createState() => _EditOperatorPageState();
}

class _EditOperatorPageState extends State<EditOperatorPage> {
  final _formKey = GlobalKey<FormState>();

  EditOperator() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyAppBar2(title: "Edit Operator"),

            // full name

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
              child: Text(
                "Name",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            MyTextField(
              controller: nameController,
              hintText: "Name",
            ),

            // email

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
              child: Text(
                "Email",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            EmailTextfield(
              controller: emailController,
            ),

            // password

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
              child: Text(
                "Password",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            PasswordTextfield(
              controller: passwordController,
            ),

            SizedBox(height: 15),

            // submit

            MyButton1(
              colored: Colors.amber.shade100,
              title: "Update",
              ontapp: () async {
                await updateFirestore(widget.docref);
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (BuildContext context) => Operators()),
                //     ModalRoute.withName('/'));
                Navigator.pop(context);
              },
            )
          ],
        ),
      )),
    );
  }
}
