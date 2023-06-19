import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:travellog/comps/myappbar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:travellog/pages/NewEntry/newentry.dart';
import 'package:travellog/utils.dart';

class StayScreen extends StatefulWidget {
  const StayScreen({super.key});

  @override
  State<StayScreen> createState() => _StayScreenState();
}

class _StayScreenState extends State<StayScreen> {
  int pdfrow = 0;
  Future<List<DocumentSnapshot>> fetchAndCheck(List<String> cityList) async {
    List<DocumentSnapshot> customerResult = [];
    final CollectionReference ticketsRef =
        FirebaseFirestore.instance.collection('jd');
    DateTime now = DateTime.now();
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final QuerySnapshot ticketsSnapshot = await ticketsRef
        .where('Jorneydate', isLessThan: endOfDay)
        .orderBy('Jorneydate', descending: true)
        .get();

    final Map<String, DocumentSnapshot> latestTickets = {};

    for (final ticketDoc in ticketsSnapshot.docs) {
      final String customerName = ticketDoc.get('Customername');

      if (!latestTickets.containsKey(customerName)) {
        latestTickets[customerName] = ticketDoc;
      }
    }

    // Process the latest tickets
    for (final customerName in latestTickets.keys) {
      final DocumentSnapshot latestTicket = latestTickets[customerName]!;
      final String toPlace = latestTicket.get('Toplace');
      if (cityList.contains(toPlace) &&
          latestTicket['TypeOFGuest'] != 'Cancel') {
        customerResult.add(latestTicket);
      }
      customerResult.sort(
        (a, b) => (b["Jorneydate"] as Timestamp).compareTo(a["Jorneydate"]),
      );

      print('Latest ticket for $customerName: $toPlace');
    }
    return customerResult;
  }

  Future addPageToPDF(
    pw.Document pdf,
    AsyncSnapshot<List<DocumentSnapshot<Object?>>> wholesnapshot,
    int start,
    int end,
  ) async {
    final font = await PdfGoogleFonts.openSansRegular();
    var data = wholesnapshot.data!.getRange(start, end);
    int count = 1;
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Table(
            defaultColumnWidth: const pw.IntrinsicColumnWidth(),
            border: pw.TableBorder.all(width: 1),
            children: [
              pw.TableRow(children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Center(
                        child:
                            pw.Text('S.NO', style: pw.TextStyle(font: font)))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Center(
                        child:
                            pw.Text('NAME', style: pw.TextStyle(font: font)))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Center(
                        child:
                            pw.Text('DOJ', style: pw.TextStyle(font: font)))),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10.0),
                  child: pw.Center(
                      child: pw.Text('TIME', style: pw.TextStyle(font: font))),
                ),
              ]),
              ...data.map((e) {
                var jdate = (e.get('Jorneydate') as Timestamp).toDate();
                return pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Center(
                        child: pw.Text('${start + count++}',
                            style: pw.TextStyle(font: font))),
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(e.get('Customername'),
                          style: pw.TextStyle(font: font))),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Center(
                        child: pw.Text(
                            '${jdate.day}/${jdate.month}/${jdate.year}',
                            style: pw.TextStyle(font: font))),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Center(
                        child: pw.Text(e.get('Traveltime'),
                            style: pw.TextStyle(font: font))),
                  ),
                ]);
              })
            ],
          ); // Center
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> cityList =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    int sno = 1;
    var user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyAppBar2(title: '$cityList'),
              FutureBuilder(
                  future: fetchAndCheck(cityList),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No results'));
                    } else {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade200),
                                onPressed: () async {
                                  Utils(context).startLoading();
                                  final pdf = pw.Document();

                                  for (int i = 0;
                                      i < snapshot.data!.length;
                                      i += 18) {
                                    await addPageToPDF(
                                        pdf,
                                        snapshot,
                                        i,
                                        i + 18 <= snapshot.data!.length
                                            ? i + 18
                                            : snapshot.data!.length);
                                  }
                                  try {
                                    const permission = Permission.storage;
                                    final status = await permission.status;
                                    debugPrint('>>>Status $status');

                                    /// here it is coming as PermissionStatus.granted
                                    if (status != PermissionStatus.granted) {
                                      await permission.request();
                                      if (!await permission.status.isGranted) {
                                        await permission.request();
                                      }
                                    }

                                    // var output =
                                    // Directory('/storage/emulated/0/Download');

                                    // if (!await output.exists()) {

                                    // }

                                    String filename =
                                        "Stay Data (${DateFormat.yMMMMd("en_US").format(DateTime.now())})_${DateTime.now()}.pdf";

                                    await DocumentFileSavePlus().saveFile(
                                        await pdf.save(),
                                        filename,
                                        "appliation/pdf");
                                    // var output = (await getExternalStorageDirectory())!;

                                    // final file = File(
                                    //     "${output.path}/Stay Data (${DateFormat.yMMMMd("en_US").format(DateTime.now())})_${DateTime.now()}.pdf");
                                    // log(output.path);
                                    // await file.writeAsBytes(await pdf.save());

                                    Fluttertoast.showToast(
                                        msg: 'File saved at Documents');
                                  } finally {
                                    Utils(context).stopLoading();
                                  }
                                },
                                child: const Text(
                                  'Save PDF to Documents',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade200,
                                  ),
                                  onPressed: () async {
                                    Utils(context).startLoading();
                                    final pdf = pw.Document();

                                    for (int i = 0;
                                        i < snapshot.data!.length;
                                        i += 18) {
                                      await addPageToPDF(
                                          pdf,
                                          snapshot,
                                          i,
                                          i + 18 <= snapshot.data!.length
                                              ? i + 18
                                              : snapshot.data!.length);
                                    }
                                    try {
                                      const permission = Permission.storage;
                                      final status = await permission.status;
                                      debugPrint('>>>Status $status');

                                      /// here it is coming as PermissionStatus.granted
                                      if (status != PermissionStatus.granted) {
                                        await permission.request();
                                        if (!await permission
                                            .status.isGranted) {
                                          await permission.request();
                                        }
                                      }
                                      var output =
                                          (await getTemporaryDirectory());
                                      String filename =
                                          "Stay Data (${DateFormat.yMMMMd("en_US").format(DateTime.now())})_${DateTime.now()}.pdf";
                                      final file =
                                          File("${output.path}/$filename");
                                      log(output.path);
                                      await file.writeAsBytes(await pdf.save());
                                      await Share.shareFiles(
                                          ["${output.path}/$filename"]);
                                    } finally {
                                      if (mounted) {
                                        Utils(context).stopLoading();
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Share PDF',
                                    style: TextStyle(color: Colors.black),
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              width: double.infinity,
                              child: Table(
                                defaultColumnWidth: IntrinsicColumnWidth(),
                                border: TableBorder.all(width: 1),
                                children: [
                                  TableRow(children: [
                                    const Padding(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'SL NO',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        )),
                                    const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('NAME'))),
                                    const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('DOJ'))),
                                    const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Center(child: Text('TIME')),
                                    ),
                                    Container()
                                  ]),
                                  ...snapshot.data!.map((e) {
                                    var jdate =
                                        (e.get('Jorneydate') as Timestamp)
                                            .toDate();
                                    return TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Center(child: Text('${sno++}')),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                            width: 100,
                                            child: Text(e.get('Customername'))),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Center(
                                            child: Text(
                                                '${jdate.day}/${jdate.month}/${jdate.year}')),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Center(
                                            child: Text(e.get('Traveltime'))),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(10),
                                        height: 30,
                                        width: 40,
                                        decoration: const BoxDecoration(
                                            border: Border()),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade300,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewEntry(
                                                            customerName: e.get(
                                                                'Customername')),
                                                  ));
                                            },
                                            child: const Text(
                                              'R',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )),
                                      )
                                    ]);
                                  })
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
