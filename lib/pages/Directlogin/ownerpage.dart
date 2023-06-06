import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/comps/cards.dart';
import 'package:travellog/comps/cattile.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/comps/textfields.dart';
import 'package:travellog/pages/CustomerList/customerlist.dart';
import 'package:travellog/pages/DialyReport/dialyreport.dart';
import 'package:travellog/pages/Directlogin/owndash.dart';
import 'package:travellog/pages/Directlogin/owntickets.dart';
import 'package:travellog/pages/NewEntry/newentry.dart';
import 'package:travellog/pages/Operators/operators.dart';

import '../Dashboard/dash.dart';

class OwnerPage extends StatelessWidget {
  const OwnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyAppBar2(
              title: "Direct Login",
            ),
            CatTile(
              ontapp: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const OwnerDashBoard(),
                  ),
                );
              },
              colored: Colors.green.shade200,
              title: "Dashboard",
              description: "Lorem ipsum dolor sit amet, \nconsectetur",
              icon:
                  "https://img.icons8.com/fluency-systems-filled/256/dashboard-layout.png",
            ),
            CatTile(
              ontapp: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const OwnerAllTickets(),
                  ),
                );
              },
              colored: Colors.cyan.shade200,
              title: "All Tickets",
              description: "Lorem ipsum dolor sit amet, \nconsectetur",
              icon:
                  "https://img.icons8.com/fluency-systems-filled/256/poll-vertical.png",
            ),
            // CatTile(
            //   ontapp: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute<void>(
            //         builder: (BuildContext context) => const OwnerOperators(),
            //       ),
            //     );
            //   },
            //   colored: Colors.pink.shade200,
            //   title: "Owners Operators",
            //   description: "Lorem ipsum dolor sit amet, \nconsectetur",
            //   icon:
            //       "https://img.icons8.com/fluency-systems-filled/256/poll-vertical.png",
            // ),
          ],
        ),
      ),
    ));
  }
}
