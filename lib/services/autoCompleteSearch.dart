import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class City {
  final String name;

  const City({
    required this.name,
  });

  static City fromJson(DocumentSnapshot json) => City(name: json['name']);
}

class CustomerName {
  final String name;

  const CustomerName({required this.name});

  static CustomerName fromJson(DocumentSnapshot json) =>
      CustomerName(name: json['CustomerName']);
}

class AutoCompleteSearch {
  /* ------------------------- City Suggestion Method ------------------------- */

  List<String> cityNames = [];

  Future<List<String>> getCitySuggestions(String query) async {
    final result =
        await FirebaseFirestore.instance.collection('citynames').get();

    cityNames.clear();

    for (var element in result.docs) {
      final city = City.fromJson(element);
      final nameLower = city.name.toLowerCase();
      final queryLower = query.toLowerCase();

      if (nameLower.contains(queryLower)) {
        cityNames.add(city.name);
      }
    }

    return cityNames;
  }

  /* -------------------------- Customer Name Method -------------------------- */

  List<String> customerNames = [];

  Future<List<String>> getCustomerSuggestions(String query) async {
    final result =
        await FirebaseFirestore.instance.collection('Customerslist').get();

    customerNames.clear();

    for (var element in result.docs) {
      final customer = CustomerName.fromJson(element);
      final nameLower = customer.name.toLowerCase();
      final queryLower = query.toLowerCase();

      if (nameLower.contains(queryLower)) {
        customerNames.add(customer.name);
      }
    }

    customerNames.sort((a, b) => a.compareTo(b));
    log(customerNames.toString());

    return customerNames;
  }
}