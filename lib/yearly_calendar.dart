import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerCalendarPage extends StatefulWidget {
  @override
  _PrayerCalendarPageState createState() => _PrayerCalendarPageState();
}

class _PrayerCalendarPageState extends State<PrayerCalendarPage> {
  Map<String, dynamic>? _prayerData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPrayerData();
  }

  Future<void> _fetchPrayerData() async {
    const url =
        'https://www.eicsanjose.org/wp/yearly_cal.json'; // Replace with actual URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _prayerData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _getMonthAbbreviation(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yearly Prayer Calendar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 25, 114, 0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text('Error fetching prayer data.'))
              : _prayerData == null
                  ? const Center(child: Text('No data available.'))
                  : ListView.builder(
                      itemCount: _prayerData!.length,
                      itemBuilder: (context, index) {
                        final entry = _prayerData!.entries.elementAt(index);
                        final date = entry.key;

                        // Format the date to "Jan 1"
                        final formattedDate = DateTime.parse(date);
                        final displayDate =
                            '${_getMonthAbbreviation(formattedDate.month)} ${formattedDate.day}';

                        final data = entry.value;

                        // Concatenate the fields for each row
                        final rowText =
                            'Fajr: ${data['fajr'] ?? 'N/A'}, Dhur: ${data['duhr'] ?? 'N/A'}, '
                            'Asr: ${data['asr'] ?? 'N/A'} \nMaghrib: ${data['maghrib'] ?? 'N/A'}, '
                            'Isha: ${data['isha'] ?? 'N/A'}';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: ListTile(
                              leading: CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(255, 232, 232, 249),
                                  child: Text(displayDate,
                                      style: const TextStyle(fontSize: 12))),
                              subtitle: Text(rowText,
                                  style: const TextStyle(fontSize: 15))),
                        );
                      },
                    ),
    );
  }
}
