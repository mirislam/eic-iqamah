import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/eic_iqamah.dart';

class IqamahProvider with ChangeNotifier {
  EICIqamah _eicIqamah = EICIqamah();
  bool _isLoading = false;
  String? _error;

  EICIqamah get eicIqamah => _eicIqamah;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchIqamahData(String prayerDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String prayerUrl =
        'https://www.eicsanjose.org/wp/iqamah_api.php?prayerDate=$prayerDate';
    
    try {
      final response = await http.get(Uri.parse(prayerUrl));
      
      if (response.statusCode == 200) {
        _eicIqamah = EICIqamah.fromJson(json.decode(response.body));
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
