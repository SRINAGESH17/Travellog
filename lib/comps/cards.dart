import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RevenueCard extends StatelessWidget {
  final String amount;

  const RevenueCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 345,
        height: 100,
        decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(9)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 23, 50, 23),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Revenue",
                        style: GoogleFonts.poppins(
                            fontSize: 23, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "RS. " + amount,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Image.network(
                    "https://img.icons8.com/fluency-systems-filled/256/dashboard-layout.png",
                    scale: 5,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
