import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';

class CPasswordPage extends StatefulWidget {
  final String docid;
  const CPasswordPage({Key? key, required this.docid}) : super(key: key);

  @override
  _CPasswordPageState createState() => _CPasswordPageState();
}

class _CPasswordPageState extends State<CPasswordPage> {
  // final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  void _changePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords don't match";
      });
      return;
    }

    try {
      // final user = _auth.currentUser;
      // await user?.updatePassword(newPassword);

      FirebaseFirestore.instance.collection("admin").doc(widget.docid).update({
        'password': newPassword,
      });

      Navigator.of(context).pop();

      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "Password Updated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);

      // show success message or navigate to a success page
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
    // on FirebaseAuthException catch (e) {
    //   setState(() {
    //     _errorMessage = e.message!;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyAppBar2(title: "Change Password"),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                      child: Text(
                        "New Password",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    PasswordTextfield(
                      controller: _newPasswordController,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
                      child: Text(
                        "Confirm Password",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    PasswordTextfield(
                      controller: _confirmPasswordController,
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              MyButton1(
                colored: Colors.amber.shade100,
                title: "Change Password",
                ontapp: _changePassword,
              )
            ],
          ),
        ),
      ),
    );
  }
}
