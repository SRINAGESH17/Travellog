import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travellog/auth/loginpage.dart';
import 'package:travellog/comps/cattile.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/date.dart';
import 'package:travellog/pages/CustomerList/customerlist.dart';
import 'package:travellog/pages/Dashboard/dash.dart';
import 'package:travellog/pages/DialyReport/dialyreport.dart';
import 'package:travellog/pages/NewEntry/entrypage.dart';
import 'package:travellog/pages/NewEntry/newentry.dart';
import 'package:travellog/pages/Operators/operators.dart';
import 'package:travellog/pages/Settingss/settingspage.dart';
import 'package:travellog/pages/Upcoming%20Tickets/select_upcomt.dart';
import 'package:travellog/revenue.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyAppBar3(
              title: "Home",
            ),
            CatTile(
              ontapp: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => Dash(),
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
                    builder: (BuildContext context) => NewEntry(),
                  ),
                );
              },
              colored: Colors.amber.shade200,
              title: "Ticket Entry",
              description: "Lorem ipsum dolor sit amet, \nconsectetur",
              icon: "https://img.icons8.com/material/256/details-popup.png",
            ),
            CatTile(
              ontapp: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const CustomerList(),
                  ),
                );
              },
              colored: Colors.blue.shade200,
              title: "Customer List",
              description: "Lorem ipsum dolor sit amet, \nconsectetur",
              icon: "https://img.icons8.com/material-rounded/256/contacts.png",
            ),
            CatTile(
              ontapp: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => DailyReport(),
                  ),
                );
              },
              colored: Colors.cyan.shade200,
              title: "All Tickets",
              description: "Lorem ipsum dolor sit amet, \nconsectetur",
              icon:
                  "https://img.icons8.com/fluency-systems-filled/256/poll-vertical.png",
            ),
            kIsAdmin
                ? CatTile(
                    ontapp: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const Operators(),
                        ),
                      );
                    },
                    colored: Colors.pink.shade200,
                    title: "Operators",
                    description: "Lorem ipsum dolor sit amet, \nconsectetur",
                    icon:
                        "https://img.icons8.com/fluency-systems-filled/256/poll-vertical.png",
                  )
                : Container(),
            // (user.email == "admin@gmail.com")
            //     ? CatTile(
            //         ontapp: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute<void>(
            //               builder: (BuildContext context) =>
            //                   const SettingPage(),
            //             ),
            //           );
            //         },
            //         colored: Colors.deepPurple.shade200,
            //         title: "Settings",
            //         description: "Lorem ipsum dolor sit amet, \nconsectetur",
            //         icon: "https://img.icons8.com/ios-filled/256/gear.png",
            //       )
            //     : Container(),
          ],
        ),
      ),
    ));
  }
}
