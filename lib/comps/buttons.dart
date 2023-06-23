import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton1 extends StatelessWidget {
  final String title;

  final Color colored;

  final VoidCallback ontapp;
  final bool isLoading;

  const MyButton1(
      {super.key,
      required this.title,
      required this.colored,
      required this.ontapp, this.isLoading = false,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
        child: Container(
            width: 395,
            height: 50,
            decoration: BoxDecoration(
                color: colored, borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.center,
            child: isLoading ? SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
            ) : Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600),
              textScaleFactor: 1.0,
            ),
        ),
      ),
    );
  }
}

class MyButton2 extends StatelessWidget {
  final String title;

  final Color colored;

  final VoidCallback ontapp;

  const MyButton2(
      {super.key,
      required this.title,
      required this.colored,
      required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(50, 30, 10, 30),
        child: Container(
            width: 155,
            height: 50,
            decoration: BoxDecoration(
                color: colored, borderRadius: BorderRadius.circular(9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  textScaleFactor: 1.0,
                ),
              ],
            )),
      ),
    );
  }
}

class MyButton3 extends StatelessWidget {
  final String title;

  final VoidCallback ontapp;

  const MyButton3({super.key, required this.title, required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
            width: 95,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  textScaleFactor: 1.0,
                ),
              ],
            )),
      ),
    );
  }
}

class MyButton4 extends StatelessWidget {
  final String title;

  final Color colored;

  final VoidCallback ontapp;

  const MyButton4(
      {super.key,
      required this.title,
      required this.colored,
      required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            width: 135,
            height: 60,
            decoration: BoxDecoration(
                color: colored, borderRadius: BorderRadius.circular(9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  textScaleFactor: 1.0,
                ),
              ],
            )),
      ),
    );
  }
}

class DeteleBut extends StatelessWidget {
  final VoidCallback ontapp;
  const DeteleBut({super.key, required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(5)),
        child: Icon(Icons.delete, size: 15),
      ),
    );
  }
}

class ChangeBut extends StatelessWidget {
  final VoidCallback ontapp;
  const ChangeBut({super.key, required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Container(
          width: 66,
          height: 25,
          decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(9)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Change",
                style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600),
                textScaleFactor: 1.0,
              ),
            ],
          )),
    );
  }
}

class PdfAbut extends StatelessWidget {
  final VoidCallback ontapp;
  const PdfAbut({super.key, required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Container(
          width: 66,
          height: 25,
          decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(9)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Add Pdf",
                style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600),
                textScaleFactor: 1.0,
              ),
            ],
          )),
    );
  }
}
