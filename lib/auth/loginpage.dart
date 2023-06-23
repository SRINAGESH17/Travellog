import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/textfields.dart';

import '../pages/homepage.dart';

late final bool kIsAdmin;
late final String kUserEmail;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // String _errorMessage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  // Future<void> signInWithEmail() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //         email: emailController.text,
  //         password: passwordController.text,
  //       );
  //       User user = userCredential.user!;
  //       print('User ${user.uid} logged in');
  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => HomePage()),
  //           ModalRoute.withName("/Home"));
  //     } on FirebaseAuthException catch (e) {
  //       var errorCode = e.code;
  //       var errorMessage = e.message;
  //       if (errorCode == 'auth/wrong-password') {
  //         setState(() {
  //           _errorMessage = 'Enter the Correct Password';
  //         });
  //       }
  //       if (e.code == 'user-not-found') {
  //         setState(() {
  //           _errorMessage = 'User not found';
  //         });
  //       } else if (e.code == 'wrong-password') {
  //         setState(() {
  //           _errorMessage = 'Incorrect password';
  //         });
  //       }
  //     } catch (e) {
  //       print('Error: $e');
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           _errorMessage,
  //           style: TextStyle(
  //             color: Colors.red,
  //           ),
  //         ),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  Future<bool?> _signInAdmin(String email, String password) async {
    final CollectionReference collectionRef = _firestore.collection('admin');
    /// Specify the field and value to search for
    const String fieldToSearch = 'email';

    try {
      final QuerySnapshot querySnapshot = await collectionRef
          .where(fieldToSearch, isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      /// Documents with the matching field value are found
      for (final DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        /// Access the document data
        final Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
        if (data == null) {
          Fluttertoast.showToast(msg: 'Some error occurred.');
          return null;
        }

        final String? fetchedPassword = data['password'] as String?;
        if (fetchedPassword == null) {
          Fluttertoast.showToast(msg: 'Some error occurred.');
          return null;
        }

        if (fetchedPassword != password) {
          Fluttertoast.showToast(
              msg: 'Incorrect password.', backgroundColor: Colors.red);
          return null;
        }

        if (!mounted) {
          return null;
        }

        return true;
      }

      return null;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<bool?> _signInOperator(String email, String password) async {
    final CollectionReference collectionRef = _firestore.collection('Operators');
    /// Specify the field and value to search for
    const String fieldToSearch = 'OperatorMail';

    try {
      final QuerySnapshot querySnapshot = await collectionRef
          .where(fieldToSearch, isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      /// Documents with the matching field value are found
      for (final DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        /// Access the document data
        final Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
        if (data == null) {
          Fluttertoast.showToast(msg: 'Some error occurred.');
          return null;
        }

        final String? fetchedPassword = data['OperatorPassword'] as String?;
        if (fetchedPassword == null) {
          Fluttertoast.showToast(msg: 'Some error occurred.');
          return null;
        }

        if (fetchedPassword != password) {
          Fluttertoast.showToast(
              msg: 'Incorrect password.', backgroundColor: Colors.red);
          return null;
        }

        if (!mounted) {
          return null;
        }

        return true;
      }

      return null;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<void> _signIn() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final bool? isAdmin = await _signInAdmin(email, password);
      if (isAdmin == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (isAdmin) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            );
        kIsAdmin = true;
        kUserEmail = email;
        return;
      }

      final bool? isOperator = await _signInOperator(email, password);
      if (isOperator == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (isOperator) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        kIsAdmin = false;
        kUserEmail = email;
        return;
      }

      Fluttertoast.showToast(msg: 'Email not found.');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoading = false;
      });
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
                    _signIn();
                  },
                  isLoading: _isLoading,
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
