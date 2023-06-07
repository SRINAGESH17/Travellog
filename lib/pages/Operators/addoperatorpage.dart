import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/Operators/operators.dart';
import 'package:travellog/utils.dart';

class AddOperator extends StatefulWidget {
  const AddOperator({super.key});

  @override
  State<AddOperator> createState() => _AddOperatorState();
}

class _AddOperatorState extends State<AddOperator> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AddOperatorfunc() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        FirebaseFirestore.instance.collection("Operators").add({
          'OperatorMail': emailController.text,
          'OperatorName': nameController.text,
          'OperatorPassword': passwordController.text,
          'isOperator': "1",
        }).then((value) => FirebaseFirestore.instance
                .collection("Operators")
                .doc(value.id)
                .update({
              'docId': value.id,
            }));
        if (!mounted) return;
        Fluttertoast.showToast(
            backgroundColor: Colors.black54,
            msg: "New Operator Added",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Operators()),
            ModalRoute.withName('/'));
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message as String,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please Enter the Correct Details",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyAppBar2(title: "Add Operator"),

            // full name

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
              child: Text(
                "Name",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
                textScaleFactor: 1.0,
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
                textScaleFactor: 1.0,
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
                textScaleFactor: 1.0,
              ),
            ),
            PasswordTextfield(
              controller: passwordController,
            ),

            const SizedBox(height: 15),

            // submit

            MyButton1(
              colored: Colors.amber.shade100,
              title: "Submit",
              ontapp: () {
                AddOperatorfunc();
              },
            )
          ],
        ),
      )),
    );
  }
}
