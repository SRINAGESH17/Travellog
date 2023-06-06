import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DownloadBox extends StatelessWidget {
  final VoidCallback ontapp;

  const DownloadBox({super.key, required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: Container(
            width: 395,
            height: 200,
            decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 50,
                ),
                SizedBox(height: 4),
                Text(
                  "Upload Document",
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  textScaleFactor: 1.0,
                ),
                SizedBox(height: 4),
                Text(
                  "Max. file size must be 5 mb",
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w400),
                  textScaleFactor: 1.0,
                ),
              ],
            )),
      ),
    );
  }
}

class UpdateBox extends StatelessWidget {
  final VoidCallback ontapp;

  const UpdateBox({super.key, required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
        child: Container(
            width: 395,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 50,
                ),
                SizedBox(height: 4),
                Text(
                  "Change Document",
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
