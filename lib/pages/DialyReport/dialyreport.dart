import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:travellog/comps/myappbar.dart';

import '../NewEntry/editentrypage.dart';

class MyPDFViewer extends StatelessWidget {
  final String url;

  MyPDFViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(
      url,
    );
  }
}

class JourneyDetailModel {
  final String id;
  final double? amount;
  final DateTime bookingDate;
  final String? customerAddedBy;
  final String? customerName;
  final String? fromPlace;
  final DateTime journeyDate;
  final String? modeOfTransport;
  final String? reference;
  final String? toPlace;
  final String? travelTime;
  final String? typeOfGuest;
  final String? month;
  final String? ticketDoc1;
  final String? ticketDoc2;

  const JourneyDetailModel({
    required this.id,
    required this.amount,
    required this.bookingDate,
    required this.customerAddedBy,
    required this.customerName,
    required this.fromPlace,
    required this.journeyDate,
    required this.modeOfTransport,
    required this.reference,
    required this.toPlace,
    required this.travelTime,
    required this.typeOfGuest,
    required this.month,
    required this.ticketDoc1,
    required this.ticketDoc2,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JourneyDetailModel &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          bookingDate == other.bookingDate &&
          customerAddedBy == other.customerAddedBy &&
          customerName == other.customerName &&
          fromPlace == other.fromPlace &&
          journeyDate == other.journeyDate &&
          modeOfTransport == other.modeOfTransport &&
          reference == other.reference &&
          toPlace == other.toPlace &&
          travelTime == other.travelTime &&
          typeOfGuest == other.typeOfGuest &&
          month == other.month &&
          ticketDoc1 == other.ticketDoc1 &&
          ticketDoc2 == other.ticketDoc2);

  @override
  int get hashCode =>
      amount.hashCode ^
      bookingDate.hashCode ^
      customerAddedBy.hashCode ^
      customerName.hashCode ^
      fromPlace.hashCode ^
      journeyDate.hashCode ^
      modeOfTransport.hashCode ^
      reference.hashCode ^
      toPlace.hashCode ^
      travelTime.hashCode ^
      typeOfGuest.hashCode ^
      month.hashCode ^
      ticketDoc1.hashCode ^
      ticketDoc2.hashCode;

  @override
  String toString() {
    return 'JourneyDetailModel{' +
        ' amount: $amount,' +
        ' bookingDate: $bookingDate,' +
        ' customerAddedBy: $customerAddedBy,' +
        ' customerName: $customerName,' +
        ' fromPlace: $fromPlace,' +
        ' journeyDate: $journeyDate,' +
        ' modeOfTransport: $modeOfTransport,' +
        ' reference: $reference,' +
        ' toPlace: $toPlace,' +
        ' travelTime: $travelTime,' +
        ' typeOfGuest: $typeOfGuest,' +
        ' month: $month,' +
        ' ticketDoc1: $ticketDoc1,' +
        ' ticketDoc2: $ticketDoc2,' +
        '}';
  }

  JourneyDetailModel copyWith({
    String? id,
    double? amount,
    DateTime? bookingDate,
    String? customerAddedBy,
    String? customerName,
    String? fromPlace,
    DateTime? journeyDate,
    String? modeOfTransport,
    String? reference,
    String? toPlace,
    String? travelTime,
    String? typeOfGuest,
    String? month,
    String? ticketDoc1,
    String? ticketDoc2,
  }) {
    return JourneyDetailModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      bookingDate: bookingDate ?? this.bookingDate,
      customerAddedBy: customerAddedBy ?? this.customerAddedBy,
      customerName: customerName ?? this.customerName,
      fromPlace: fromPlace ?? this.fromPlace,
      journeyDate: journeyDate ?? this.journeyDate,
      modeOfTransport: modeOfTransport ?? this.modeOfTransport,
      reference: reference ?? this.reference,
      toPlace: toPlace ?? this.toPlace,
      travelTime: travelTime ?? this.travelTime,
      typeOfGuest: typeOfGuest ?? this.typeOfGuest,
      month: month ?? this.month,
      ticketDoc1: ticketDoc1 ?? this.ticketDoc1,
      ticketDoc2: ticketDoc2 ?? this.ticketDoc2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'amount': this.amount,
      'bookingDate': this.bookingDate,
      'customerAddedBy': this.customerAddedBy,
      'customerName': this.customerName,
      'fromPlace': this.fromPlace,
      'journeyDate': this.journeyDate,
      'modeOfTransport': this.modeOfTransport,
      'reference': this.reference,
      'toPlace': this.toPlace,
      'travelTime': this.travelTime,
      'typeOfGuest': this.typeOfGuest,
      'month': this.month,
      'ticketDoc1': this.ticketDoc1,
      'ticketDoc2': this.ticketDoc2,
    };
  }

  factory JourneyDetailModel.fromMap(Map<String, dynamic> map) {
    final bookingDate = DateTime.parse(
      (map['Bookingdate'] as Timestamp? ?? Timestamp.now())
          .toDate()
          .toIso8601String(),
    );
    final journeyDate = DateTime.parse(
      (map['Jorneydate'] as Timestamp? ?? Timestamp.now())
          .toDate()
          .toIso8601String(),
    );

    return JourneyDetailModel(
      id: map['id'],
      amount: double.tryParse(map['Amount'] ?? ''),
      bookingDate: bookingDate,
      customerAddedBy: map['Customeraddedby'] as String?,
      customerName: map['Customername'] as String?,
      fromPlace: map['Fromplace'] as String?,
      journeyDate: journeyDate,
      modeOfTransport: map['Modeoftransport'] as String?,
      reference: map['Reference'] as String?,
      toPlace: map['Toplace'] as String?,
      travelTime: map['Traveltime'] as String?,
      typeOfGuest: map['TypeOFGuest'] as String?,
      month: map['month'] as String?,
      ticketDoc1: map['ticketDoc'] as String?,
      ticketDoc2: map['ticketDoc2'] as String?,
    );
  }
}

class DailyReport extends StatefulWidget {
  const DailyReport({super.key});

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  final _searchController = TextEditingController();
  final List<JourneyDetailModel> _journeyDetails = [];
  final List<JourneyDetailModel> _filteredJourneyDetails = [];
  late double _totalAmount;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  MyAppBar2(
                    title: "All Tickets",
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            "All Tickets is ${_journeyDetails.length}",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textScaleFactor: 1.0,
                          ),
                          SizedBox(height: 20),
                          _buildTotalAmountCard(),
                          SizedBox(height: 20),
                          _buildSearchTextField(),
                          SizedBox(height: 20),
                          _buildTicketList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTicketList() => Expanded(
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 20),
          itemCount: _filteredJourneyDetails.length,
          itemBuilder: (context, index) =>
              _buildTicketCard(_filteredJourneyDetails[index]),
          separatorBuilder: (context, index) => SizedBox(height: 10),
        ),
      );

  void _searchByName(String term) {
    if (term.trim().isEmpty) {
      _filteredJourneyDetails.clear();
      _filteredJourneyDetails.addAll(_journeyDetails);
      setState(() {});
      return;
    }

    _filteredJourneyDetails.clear();
    _filteredJourneyDetails.addAll(
      _journeyDetails
          .where(
            (journey) =>
                journey.customerName
                    ?.toLowerCase()
                    .contains(term.toLowerCase()) ??
                false,
          )
          .toList(),
    );
    setState(() {});
  }

  double _calcTotalAmount(List<JourneyDetailModel> journeys) {
    double total = 0.0;
    for (final journey in journeys) {
      total += journey.amount ?? 0.0;
    }
    return total;
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    late final List<JourneyDetailModel> journeys;

    try {
      /// Fetching all journeys
      journeys = await _fetchJourneyDetails();

      /// Sorting by bookingDate in ascending
      journeys.sort(
        (a, b) => b.bookingDate.compareTo(a.bookingDate),
      );

      /// Calc total amount
      _totalAmount = _calcTotalAmount(journeys);

      _journeyDetails.clear();
      _journeyDetails.addAll([...journeys]);
      _filteredJourneyDetails.clear();
      _filteredJourneyDetails.addAll([...journeys]);
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: e.toString());
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<List<JourneyDetailModel>> _fetchJourneyDetails() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('jd').get();
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        snapshot.docs;
    late final List<JourneyDetailModel> journeys = [];
    for (final doc in docs) {
      journeys
          .add(JourneyDetailModel.fromMap(doc.data()..addAll({'id': doc.id})));
    }
    return journeys;
  }

  String _getFormattedDate(DateTime dateTime) =>
      DateFormat('dd-MM-yyyy').format(dateTime);

  String _getFormattedTime(DateTime dateTime) =>
      DateFormat('HH:MM').format(dateTime);

  Future<void> _showConfirmDialog(JourneyDetailModel journey) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const SingleChildScrollView(
            child: Text('Are you sure you want to delete entry?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => _deleteTicket(journey),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTicket(JourneyDetailModel journey) async {
    try {
      await FirebaseFirestore.instance
          .collection('jd')
          .doc(journey.id)
          .delete();

      _searchController.clear();
      _journeyDetails.removeWhere((element) => element.id == journey.id);
      _filteredJourneyDetails.clear();
      _filteredJourneyDetails.addAll([..._journeyDetails]);

      _totalAmount = _calcTotalAmount(_filteredJourneyDetails);

      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "Entry Deleted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();

      setState(() {});
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(
          backgroundColor: Colors.black54,
          msg: "Failed to delete entry.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> _editTicket(JourneyDetailModel journey) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EditEntryPage(docid: journey.id),
      ),
    );

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _fetchById(journey.id);
    final data = doc.data();

    if (data == null) {
      return;
    }

    _searchController.clear();
    _journeyDetails.removeWhere((element) => element.id == journey.id);
    _journeyDetails.add(
      JourneyDetailModel.fromMap(
        data..addAll({'id': doc.id}),
      ),
    );

    _journeyDetails.sort(
      (a, b) => b.bookingDate.compareTo(a.bookingDate),
    );

    _filteredJourneyDetails.clear();
    _filteredJourneyDetails.addAll([..._journeyDetails]);

    _totalAmount = _calcTotalAmount(_filteredJourneyDetails);

    setState(() {});
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchById(String id) async {
    return await FirebaseFirestore.instance.collection('jd').doc(id).get();
  }

  void _viewPdf(String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyPDFViewer(url: pdfUrl),
      ),
    );
  }

  Widget _buildTicketCard(JourneyDetailModel journey) => Container(
        key: UniqueKey(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    journey.customerName ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    journey.amount?.toStringAsFixed(0) ?? '0',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${journey.fromPlace ?? ''} to ${journey.toPlace ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 20),
                Visibility(
                  visible: journey.ticketDoc1 != null &&
                      journey.ticketDoc1!.isNotEmpty,
                  child: InkWell(
                    onTap: () => _viewPdf(journey.ticketDoc1!),
                    child: Image.asset(
                      'assets/icons/pdf1.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Visibility(
                  visible: journey.ticketDoc2 != null &&
                      journey.ticketDoc2!.isNotEmpty,
                  child: InkWell(
                    onTap: () => _viewPdf(journey.ticketDoc2!),
                    child: Image.asset(
                      'assets/icons/pdf2.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _getFormattedDate(journey.bookingDate),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getFormattedTime(journey.bookingDate),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 20),
                _buildIconButton(Icons.edit, () => _editTicket(journey)),
                SizedBox(width: 4),
                _buildIconButton(
                    Icons.delete, () => _showConfirmDialog(journey)),
              ],
            ),
            SizedBox(height: 15),
            Text(
              journey.modeOfTransport ?? '',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      );

  Widget _buildSearchTextField() => TextField(
        controller: _searchController,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey[500])),
        onChanged: _searchByName,
      );

  String _getFormattedAmount() => NumberFormat.currency(
        decimalDigits: 0,
        symbol: '₹',
        name: 'INR',
        locale: 'HI',
      ).format(_totalAmount);

  Widget _buildTotalAmountCard() => Container(
        width: double.infinity,
        color: Colors.green.shade200,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(
          _getFormattedAmount(),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _buildIconButton(IconData iconData, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            iconData,
            size: 16,
            color: Colors.black,
          ),
        ),
      );
}
