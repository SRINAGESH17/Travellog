import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/auth/adminlogin.dart';
import 'package:travellog/pages/Directlogin/ownerpage.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/CustomerList/customerlist.dart';
import 'package:travellog/pages/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        User user = userCredential.user!;
        print('User ${user.uid} logged in');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            ModalRoute.withName("/Home"));
      } on FirebaseAuthException catch (e) {
        var errorCode = e.code;
        var errorMessage = e.message;
        if (errorCode == 'auth/wrong-password') {
          setState(() {
            _errorMessage = 'Enter the Correct Password';
          });
        }
        if (e.code == 'user-not-found') {
          setState(() {
            _errorMessage = 'User not found';
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            _errorMessage = 'Incorrect password';
          });
        }
      } catch (e) {
        print('Error: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _errorMessage,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                        fontSize: 21, fontWeight: FontWeight.w600),
                    textScaleFactor: 1.0,
                  ),
                ),
                SizedBox(height: 30),
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
                SizedBox(height: 20),

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
                SizedBox(height: 20),

                MyButton1(
                  title: "Login",
                  colored: Colors.pink.shade200,
                  ontapp: () {
                    signInWithEmail();
                  },
                ),

                //

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Flexible(
                //       child: Padding(
                //         padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                //         child: Divider(),
                //       ),
                //     ),
                //     Text(
                //       "OR",
                //       style: GoogleFonts.poppins(
                //         color: Colors.grey.shade700,
                //         fontSize: 14,
                //         fontWeight: FontWeight.w400,
                //       ),
                //     ),
                //     Flexible(
                //       child: Padding(
                //         padding: const EdgeInsets.fromLTRB(10, 10, 30, 10),
                //         child: Divider(),
                //       ),
                //     ),
                //   ],
                // ),

                // admin

                // owner

                // MyButton1(
                //   title: "Direct Login",
                //   colored: Colors.green.shade200,
                //   ontapp: () async {
                //     Navigator.of(context).push(
                //       MaterialPageRoute<void>(
                //         builder: (BuildContext context) => const OwnerPage(),
                //       ),
                //     );
                //   },
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
