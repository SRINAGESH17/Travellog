// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:travellog/comps/buttons.dart';
// import 'package:travellog/comps/textfields.dart';
// import 'package:travellog/pages/homepage.dart';
//
// class AdminLogin extends StatefulWidget {
//   const AdminLogin({super.key});
//
//   @override
//   State<AdminLogin> createState() => _AdminLoginState();
// }
//
// class _AdminLoginState extends State<AdminLogin> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   String _errorMessage = '';
//
//   Future<void> signInWithEmail() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: emailController.text,
//           password: passwordController.text,
//         );
//         User user = userCredential.user!;
//         print('User ${user.uid} logged in');
//        Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomePage()
//       ),
//      ModalRoute.withName("/Home")
//     );
//       } on FirebaseAuthException catch (e) {
//         var errorCode = e.code;
//         var errorMessage = e.message;
//         if (errorCode == 'auth/wrong-password') {
//           setState(() {
//             _errorMessage = 'Enter the Correct Password';
//           });
//         }
//         if (e.code == 'user-not-found') {
//           setState(() {
//             _errorMessage = 'User not found';
//           });
//         } else if (e.code == 'wrong-password') {
//           setState(() {
//             _errorMessage = 'Incorrect password';
//           });
//         }
//       } catch (e) {
//         print('Error: $e');
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             _errorMessage,
//             style: TextStyle(
//               color: Colors.red,
//             ),
//           ),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 80),
//                 Center(
//                   child: Text(
//                     "Login as Admin",
//                     style: GoogleFonts.poppins(
//                         fontSize: 21, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 // email
//
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
//                   child: Text(
//                     "Email",
//                     style: GoogleFonts.poppins(
//                         fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                 ),
//                 EmailTextfield(
//                   controller: emailController,
//                 ),
//                 SizedBox(height: 20),
//
//                 // password
//
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(30, 10, 10, 5),
//                   child: Text(
//                     "Password",
//                     style: GoogleFonts.poppins(
//                         fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                 ),
//                 PasswordTextfield(
//                   controller: passwordController,
//                 ),
//                 SizedBox(height: 20),
//
//                 MyButton1(
//                   title: "Login",
//                   colored: Colors.blue.shade200,
//                   ontapp: () {
//                     signInWithEmail();
//                   },
//                 ),
//                 //
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
