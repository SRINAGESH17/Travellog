import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/auth/loginpage.dart';
import 'package:travellog/pages/Settingss/settingspage.dart';

class MyAppBar extends StatefulWidget {
  final String title;

  const MyAppBar({super.key, required this.title});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 30,
            height: 30,
          ),
          Text(
            widget.title,
            style:
                GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w600),
            textScaleFactor: 1.0,
          ),
          GestureDetector(
            onTap: () async {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    // <-- SEE HERE
                    title: const Text(
                      'Logout',
                      textScaleFactor: 1.0,
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const <Widget>[
                          Text(
                            'Are you sure want to Logout',
                            textScaleFactor: 1.0,
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'No',
                          textScaleFactor: 1.0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Yes',
                          textScaleFactor: 1.0,
                        ),
                        onPressed: () async {
                          await _auth.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(
              Icons.logout,
              size: 18,
            ),
          )
        ],
      ),
    );
  }
}

class MyAppBar2 extends StatefulWidget {
  final String title;

  const MyAppBar2({super.key, required this.title});

  @override
  State<MyAppBar2> createState() => _MyAppBar2State();
}

class _MyAppBar2State extends State<MyAppBar2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_sharp,
              size: 22,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.title,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w600),
                textScaleFactor: 1.0,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
          ),
        ],
      ),
    );
  }
}

class MyAppBar3 extends StatefulWidget {
  final String title;

  const MyAppBar3({super.key, required this.title});

  @override
  State<MyAppBar3> createState() => _MyAppBar3State();
}

class _MyAppBar3State extends State<MyAppBar3> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 30,
            height: 30,
          ),
          Text(
            widget.title,
            style:
                GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w600),
            textScaleFactor: 1.0,
          ),
          GestureDetector(
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SettingPage(),
                ),
              );
            },
            child: const Icon(
              Icons.settings,
              size: 22,
            ),
          )
        ],
      ),
    );
  }
}

class logoutButton extends StatefulWidget {
  const logoutButton({super.key});

  @override
  State<logoutButton> createState() => _logoutButtonState();
}

class _logoutButtonState extends State<logoutButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              // <-- SEE HERE
              title: const Text(
                'Logout',
                textScaleFactor: 1.0,
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text(
                      'Are you sure want to Logout',
                      textScaleFactor: 1.0,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'No',
                    textScaleFactor: 1.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Yes',
                    textScaleFactor: 1.0,
                  ),
                  onPressed: () async {
                    if (_auth.currentUser!.email == 'admin@gmail.com') {
                      var fcmToken =
                          await FirebaseMessaging.instance.getToken();
                      var snapshot = await FirebaseFirestore.instance
                          .collection("FcmToken")
                          .where("email", isEqualTo: 'admin@gmail.com')
                          .get();
                      var docId = snapshot.docs.first.id;
                      List fcmList = snapshot.docs.first.get('fcmTokens');
                      if (fcmList.contains(fcmToken)) {
                        fcmList.remove(fcmToken);
                        FirebaseFirestore.instance
                            .collection("FcmToken")
                            .doc(docId)
                            .update({'fcmTokens': fcmList});
                      }
                    }
                    await _auth.signOut();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                ),
              ],
            );
          },
        );
      },
      child: Row(
        children: [
          Text(
            "Logout",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            textScaleFactor: 1.0,
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.logout,
            size: 18,
          ),
        ],
      ),
    );
  }
}
