import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travellog/auth/loginpage.dart';
import 'package:travellog/comps/buttons.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:travellog/pages/DialyReport/dialyreport.dart';
import 'package:travellog/pages/NewEntry/editentrypage.dart';

class FilterDeleteScreen extends StatefulWidget {
  const FilterDeleteScreen({super.key});

  @override
  State<FilterDeleteScreen> createState() => _FilterDeleteScreenState();
}

class _FilterDeleteScreenState extends State<FilterDeleteScreen> {
  DateTime? selectedFromJourneyDate, selectedToJourneyDate;
  DateTime selectedFromBookingDate = DateTime(2020), //past
      selectedToBookingDate = DateTime(3000); //future
  String _bookingfilterfrom = "From";
  String _bookingfilterto = "To";
  String _journeyfilterfrom = "From";
  String _journeyfilterto = "To";
  int sum = 0;
  bool isLoading = true;
  // var user = FirebaseAuth.instance.currentUser;

  totalamount(
      Query query, DateTime fromBookingDate, DateTime toBookingDate) async {
    var snapshot = await query.get();
    sum = 0;
    for (var data in snapshot.docs) {
      var date = data['Bookingdate'].toDate();
      var journeyDate = data['Jorneydate'].toDate();
      journeyDate = DateFormat('dd/MM/yy').format(journeyDate);
      if ((date.isAfter(fromBookingDate) ||
              date.isAtSameMomentAs(fromBookingDate)) &&
          (date.isBefore(toBookingDate) ||
              date.isAtSameMomentAs(toBookingDate))) {
        sum++;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  DateTime roundToLastMinuteOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalamount(querySelect(), selectedFromBookingDate, selectedToBookingDate);
  }

  Query querySelect() {
    return FirebaseFirestore.instance
        .collection("jd")
        .where("Jorneydate", isGreaterThanOrEqualTo: selectedFromJourneyDate)
        .where("Jorneydate", isLessThanOrEqualTo: selectedToJourneyDate)
        .orderBy("Jorneydate");
  }

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          const MyAppBar2(title: 'Delete Journey Details'),
          SizedBox(
            height: 10,
          ),
          isLoading
              ? CircularProgressIndicator()
              : Text("Ticket count:  $sum",
                  style: GoogleFonts.poppins(
                      fontSize: 21, fontWeight: FontWeight.w600)),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: Colors.black26),
                    left: BorderSide(width: 1.0, color: Colors.black26),
                    right: BorderSide(width: 1.0, color: Colors.black26),
                    bottom: BorderSide(width: 1.0, color: Colors.black26),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                        child: Text(
                          _bookingfilterfrom,
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {}),
                    IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Colors.black87, size: 18),
                      onPressed: () async {
                        final DateTime? d = await showDatePicker(
                          context: context,
                          initialDate: selectedFromBookingDate == DateTime(2020)
                              ? DateTime.now()
                              : selectedFromBookingDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(3000),
                        );
                        if (d != null) {
                          selectedFromBookingDate = d;

                          _bookingfilterfrom = DateFormat('dd-MM-yy').format(d);
                          totalamount(querySelect(), selectedFromBookingDate,
                              selectedToBookingDate);
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: Colors.black26),
                    left: BorderSide(width: 1.0, color: Colors.black26),
                    right: BorderSide(width: 1.0, color: Colors.black26),
                    bottom: BorderSide(width: 1.0, color: Colors.black26),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Text(
                        _bookingfilterto,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Colors.black87, size: 18),
                      onPressed: () async {
                        final DateTime? d = await showDatePicker(
                          context: context,
                          initialDate: selectedToBookingDate == DateTime(3000)
                              ? DateTime.now()
                              : selectedToBookingDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(3000),
                        );
                        if (d != null) {
                          selectedToBookingDate = roundToLastMinuteOfDay(d);

                          _bookingfilterto = DateFormat('dd-MM-yy').format(d);
                          totalamount(querySelect(), selectedFromBookingDate,
                              selectedToBookingDate);
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: Colors.black26),
                      left: BorderSide(width: 1.0, color: Colors.black26),
                      right: BorderSide(width: 1.0, color: Colors.black26),
                      bottom: BorderSide(width: 1.0, color: Colors.black26),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                          child: Text(
                            _journeyfilterfrom,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {}),
                      IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: Colors.black87, size: 18),
                        onPressed: () async {
                          final DateTime? d = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedFromJourneyDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(3000),
                          );
                          if (d != null) {
                            selectedFromJourneyDate = d;

                            _journeyfilterfrom =
                                DateFormat('dd-MM-yy').format(d);
                            totalamount(querySelect(), selectedFromBookingDate,
                                selectedToBookingDate);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: Colors.black26),
                      left: BorderSide(width: 1.0, color: Colors.black26),
                      right: BorderSide(width: 1.0, color: Colors.black26),
                      bottom: BorderSide(width: 1.0, color: Colors.black26),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          _journeyfilterto,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: Colors.black87, size: 18),
                        onPressed: () async {
                          final DateTime? d = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedToJourneyDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(3000),
                          );
                          if (d != null) {
                            selectedToJourneyDate = roundToLastMinuteOfDay(d);

                            _journeyfilterto = DateFormat('dd-MM-yy').format(d);
                            totalamount(querySelect(), selectedFromBookingDate,
                                selectedToBookingDate);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: MyButton3(
                title: "Delete",
                ontapp: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Delete Filtered Journey Details'),
                        content: Text('Are you sure you want to delete?'),
                        actions: [
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () async {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Enter Password'),
                                    content: TextField(
                                      controller: passwordController,
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Continue'),
                                        onPressed: () async {
                                          final passSnap =
                                              await FirebaseFirestore.instance
                                                  .collection('admin')
                                                  .get();
                                          final password =
                                              passSnap.docs.first['password'];
                                          if (password == null) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Something went wrong',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                              Navigator.pop(context);
                                            }
                                          }
                                          if (passwordController.text ==
                                              password) {
                                            var snapshot =
                                                await querySelect().get();
                                            for (var data in snapshot.docs) {
                                              var date =
                                                  data['Bookingdate'].toDate();
                                              var journeyDate =
                                                  data['Jorneydate'].toDate();
                                              journeyDate =
                                                  DateFormat('dd/MM/yy')
                                                      .format(journeyDate);
                                              if ((date.isAfter(
                                                          selectedFromBookingDate) ||
                                                      date.isAtSameMomentAs(
                                                          selectedFromBookingDate)) &&
                                                  (date.isBefore(
                                                          selectedToBookingDate) ||
                                                      date.isAtSameMomentAs(
                                                          selectedToBookingDate))) {
                                                data.reference.delete();
                                              }
                                            }
                                            if (mounted) {
                                              Navigator.pop(context);
                                            }
                                            Fluttertoast.showToast(
                                                backgroundColor: Colors.black54,
                                                msg: "Filtered tickets deleted",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.SNACKBAR,
                                                timeInSecForIosWeb: 1,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Incorrect Password',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                }),
          ),
          Expanded(
            child: StreamBuilder(
                stream: querySelect().snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('No Data Found');
                  }
                  final now = DateTime.now();

                  if (!snapshot.data!.docs.any((element) {
                    // DateTime date = selectedDateType != null
                    //     ? element['$selectedDateType'].toDate()
                    //     : element['Bookingdate'].toDate();

                    DateTime date = element['Bookingdate'].toDate();

                    return
                        //  ((element['Customername'] as String)
                        //             .startsWith(searchController.text) &&
                        ((date.isAfter(selectedFromBookingDate) ||
                                    date.isAtSameMomentAs(
                                        selectedFromBookingDate)) &&
                                (date.isBefore(selectedToBookingDate) ||
                                    date.isAtSameMomentAs(
                                        selectedToBookingDate)))
                            ? true
                            : false;
                  })) return Center(child: const Text('No Data Found'));
                  snapshot.data!.docs.sort(
                      (a, b) => a['Jorneydate'].compareTo(b['Jorneydate']));
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((document) {
                      DateTime jdate = document['Jorneydate'].toDate();
                      // DateTime date = selectedDateType != null
                      //     ? document['$selectedDateType'].toDate()
                      //     : document['Bookingdate'].toDate();
                      DateTime date = document['Bookingdate'].toDate();

                      if
                          //  ((document['Customername'] as String)
                          //         .startsWith(searchController.text) &&
                          ((date.isAfter(selectedFromBookingDate) ||
                                  date.isAtSameMomentAs(
                                      selectedFromBookingDate)) &&
                              (date.isBefore(selectedToBookingDate) ||
                                  date.isAtSameMomentAs(
                                      selectedToBookingDate))) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(19, 5, 19, 5),
                          child: Container(
                            width: 90,
                            height: 200,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(9)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 10, 30, 18),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        document['Customername'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        document['Amount'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        document['Fromplace'] +
                                            " to " +
                                            document['Toplace'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Row(
                                        children: [
                                          StreamBuilder<Object>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("jd")
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (document["ticketDoc"] ==
                                                    "") {
                                                  return Container();
                                                }

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyPDFViewer(
                                                                url: document[
                                                                    'ticketDoc']),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Image.asset(
                                                      "assets/icons/pdf1.png",
                                                      scale: 1.5,
                                                    ),
                                                  ),
                                                );
                                              }),
                                          SizedBox(width: 5),
                                          StreamBuilder<Object>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("jd")
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (document["ticketDoc2"] ==
                                                    "") {
                                                  return Container();
                                                }

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyPDFViewer(
                                                                url: document[
                                                                    'ticketDoc2']),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Image.asset(
                                                      "assets/icons/pdf2.png",
                                                      scale: 1.5,
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 20),
                                        child: Text(
                                          '${jdate.day}/${jdate.month}/${jdate.year}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 20, 21),
                                        child: Text(
                                          document['Traveltime'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      kIsAdmin
                                          ? Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute<void>(
                                                        builder: (BuildContext
                                                                context) =>
                                                            EditEntryPage(
                                                                docid: document
                                                                    .id),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: const Icon(
                                                        Icons.edit,
                                                        size: 15),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                GestureDetector(
                                                  onTap: () async {
                                                    totalamount(
                                                        querySelect(),
                                                        selectedFromBookingDate,
                                                        selectedToBookingDate);
                                                    showDialog<void>(
                                                      context: context,
                                                      barrierDismissible:
                                                          false, // user must tap button!
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          // <-- SEE HERE
                                                          title: const Text(
                                                              'Delete Entry'),
                                                          content:
                                                              const SingleChildScrollView(
                                                            child: Text(
                                                                'Are you sure want to Entry?'),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  'No'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Yes'),
                                                              onPressed:
                                                                  () async {
                                                                totalamount(
                                                                    querySelect(),
                                                                    selectedFromBookingDate,
                                                                    selectedToBookingDate);
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'jd')
                                                                    .doc(
                                                                        document
                                                                            .id)
                                                                    .delete();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();

                                                                Fluttertoast.showToast(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .black54,
                                                                    msg:
                                                                        "Entry Deleted",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .SNACKBAR,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: const Icon(
                                                        Icons.delete,
                                                        size: 15),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  Text(
                                    document['Modeoftransport'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }).toList(),
                  );
                }),
          ),
        ],
      )),
    );
  }
}
