// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddFieldsScreen extends StatefulWidget {
//   @override
//   _AddFieldsScreenState createState() => _AddFieldsScreenState();
// }
//
// class _AddFieldsScreenState extends State<AddFieldsScreen> {
//   int _total = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Fields'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               child: Text('Calculate Total'),
//               onPressed: () async {
//                 final snapshot = await FirebaseFirestore.instance
//                     .collection('JorneyDetials')
//                     .get();
//                 int sum = 0;
//                 snapshot.docs
//                     .forEach((doc) => sum += doc.data()['Amount'] as int);
//                 setState(() {
//                   _total = sum;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             Text('Total: $_total'),
//           ],
//         ),
//       ),
//     );
//   }
// }
