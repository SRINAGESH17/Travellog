import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CatTile extends StatelessWidget {
  final Color colored;

  final String title;

  final String description;

  final String icon;

  final VoidCallback ontapp;

  const CatTile(
      {super.key,
      required this.colored,
      required this.title,
      required this.description,
      required this.icon,
      required this.ontapp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontapp,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 335,
            height: 95,
            decoration: BoxDecoration(
                color: colored, borderRadius: BorderRadius.circular(9)),
            child: Column(
              children: [
                SizedBox(height: 30),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          textScaleFactor: 1.0,
                        ),
                      ),
                      Image.network(
                        icon,
                        scale: 8,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
