import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travellog/comps/myappbar.dart';

class DateViewScreen extends StatefulWidget {
  const DateViewScreen(
      {super.key, required this.guestFilter, this.todayFilter = false});
  final bool guestFilter;
  final bool todayFilter;
  @override
  State<DateViewScreen> createState() => _DateViewScreenState();
}

class _DateViewScreenState extends State<DateViewScreen> {
  Map<String, int> ticketDisplay(List snapshot) {
    Map<String, int> dayCount = {};
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    int difference = endOfMonth.difference(today).inDays;
    for (int i = 0; i < difference + 1; i++) {
      dayCount[DateFormat('dd/MM/yy').format(today.add(Duration(days: i)))] = 0;
    }
    for (var data in snapshot) {
      if (widget.guestFilter && data['TypeOFGuest'] == 'Guest' ||
          (data['Modeoftransport'] == 'Flight' && data['rev'] <= 1000)) {
        continue;
      }
      var journeyDateTime = data['Jorneydate'].toDate() as DateTime;
      var journeyDate = data['Jorneydate'].toDate();
      journeyDate = DateFormat('dd/MM/yy').format(journeyDate);
      if (widget.todayFilter) {
        if (dayCount.containsKey(journeyDate) && journeyDateTime.isAfter(now)) {
          dayCount[journeyDate] = dayCount[journeyDate]! + 1;
        }
      } else {
        if (dayCount.containsKey(journeyDate)) {
          dayCount[journeyDate] = dayCount[journeyDate]! + 1;
        }
      }
    }

    return dayCount;
  }

  @override
  Widget build(BuildContext context) {
    var settings =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var ticketList = settings['ticketList'];
    var displayMap = ticketDisplay(ticketList);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            MyAppBar2(title: 'Upcoming tickets'),
            Container(
                width: 300,
                color: Colors.green.shade200,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...displayMap.entries.map(
                      (entry) {
                        return entry.value != 0
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Spacer(
                                    flex: 4,
                                  ),
                                  Text(
                                    '${entry.key}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '  :  ',
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${entry.value}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Spacer(
                                    flex: 4,
                                  )
                                ],
                              )
                            : Container();
                      },
                    ).toList(),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
