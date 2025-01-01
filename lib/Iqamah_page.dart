import 'package:firebase_core/firebase_core.dart';

import 'constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'eic_iqamah2.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class IqamahPage extends StatefulWidget {
  IqamahPage({Key? key}) : super(key: key);

  @override
  State<IqamahPage> createState() => _IqamahPageState();
}

class _IqamahPageState extends State<IqamahPage> {
  EICIqamah eicIqamah = new EICIqamah();
  bool _loaded = false;
  late final FirebaseMessaging _messaging;
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime firstDate = new DateTime(now.year, now.month, now.day);
    DateTime lastDate = firstDate.add(Duration(days: 60));
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(
              primary: Color.fromARGB(255, 15, 84, 0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null && selected != selectedDate) {
      _loaded = false;
      String formattedDate = DateFormat('y-MM-dd').format(selected);
      print("Selected formatted date $formattedDate");
      fetchIqamahData(formattedDate).then((data) => setState(() {
            eicIqamah = data;
            _loaded = true;
          }));
    }
  } //_selectDate

  void registerNotification() async {
    //print("Step 1");
    // 1. Initialize the Firebase app
    //await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    //print("Step 2");
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    // print("Step 3");

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      _messaging.getToken().then((token) async {
        print('Token got:');
        print(token); // Print the Token in Console
        //save it to EIC database
        String platform = 'android';
        if (Platform.isIOS) {
          platform = 'iOS';
        }
        Map data = {
          "command": "register",
          "deviceToken": token,
          "platform": platform
        };
        var response = await registerDeviceToEIC(data);
      });

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        var snackBar = SnackBar(
            content: const Text('Hi, I am a SnackBar!'),
            backgroundColor: (Colors.black12),
            action: SnackBarAction(
              label: 'dismiss',
              onPressed: () {},
            ));
        //Scaffold.of(context).showSnackBar(snackBar);

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  } //registerNotification

  Future<http.Response> registerDeviceToEIC(Map data) async {
    var url = 'https://www.eicsanjose.org/wp/fb_register.php';
    print('Sending device registration to EICv${url}: ${data}');

    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    print("EIC Response: ${response.statusCode}");
    print("${response.body}");
    return response;
  } //registerDeviceToEIC

  @override
  void initState() {
    // call register
    print('Call registerNotification');
    registerNotification();
    // today's date to send to api server
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('y-MM-dd').format(now);
    //print("Formatted date ${formattedDate}");

    // load json here
    fetchIqamahData(formattedDate).then((data) => setState(() {
          eicIqamah = data;
          _loaded = true;
        }));
  }

  Future<EICIqamah> fetchIqamahData(String prayerDate) async {
    String prayerUrl =
        'https://www.eicsanjose.org/wp/iqamah_api.php?prayerDate=' + prayerDate;
    print("Get prayers: " + prayerUrl);
    final response = await http.get(Uri.parse(prayerUrl));
    print("Got the json?");

    try {
      eicIqamah = EICIqamah.fromJson(json.decode(response.body));
      print('----- No Exception in json decoding');
      print(response.body);
      print(eicIqamah.notices);
    } on FormatException catch (fe) {
      print('---------');
      print(fe.message);
      print(fe.toString());
    }
    //print(response.body);

    return eicIqamah;
  } //fetchIqamahData

  var notificationTexts = "";
  List<Widget> _getActionButtons(BuildContext context) {
    if (eicIqamah.notices != null) {
      print(
          '-->Notices not empty ${eicIqamah.notices} ${eicIqamah.notices!.isEmpty}');
      //notificationTexts = eicIqamah.events?.join('\n');
      eicIqamah.notices!.forEach((element) {
        print('Notification element: ${element}');
        notificationTexts = notificationTexts + '\n' + element;
      });
    } else {
      print('No notices/prayer time changes ${eicIqamah}');
    }
    print('Notification Texts: =${notificationTexts}=');
    var notifyIconButton = IconButton(
        icon: const Icon(Icons.notifications_active),
        tooltip: 'Notifications',
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Prayer Time Changes',
                style: TextStyle(color: Color.fromARGB(255, 25, 114, 0)),
              ),
              content: Text(notificationTexts),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });

    var calIconButton = IconButton(
        icon: const Icon(Icons.calendar_month),
        tooltip: 'Show Calendar',
        onPressed: () {
          _selectDate(context);
        });
    List<Widget> buttons = [];
    //if (eicIqamah.notices != null && eicIqamah.notices!.isNotEmpty) {
    if (notificationTexts.length > 10) {
      buttons.add(calIconButton);
      buttons.add(notifyIconButton);
    } else {
      buttons.add(calIconButton);
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat("MMM dd, yyyy");
    String dateString = dateFormat.format(DateTime.now());

    String hijriMonth = "Undefined";
    //String hijriDay = "Undefined";
    //String hijriYear = "Undefined";
    int hijriYear = 1492;
    int hijriDay = 1;
    String hijriDate = "Undefined";
    // assign the values
    hijriYear = eicIqamah.hijriYear ?? 1492;
    hijriDay = eicIqamah.hijriDay ?? 1;
    hijriMonth = eicIqamah.hijriMonth ?? '1';

    int eventsCount = 0;
    List<String> tmpEvents = [];
    tmpEvents = eicIqamah.events ?? [];
    eventsCount = tmpEvents.length;

    //print('Prayer date: ${eicIqamah.toJson()}');

    String dateLabel = dateString +
        '\n' +
        hijriMonth +
        '' +
        ' ' +
        hijriDay.toString() +
        ', ' +
        hijriYear.toString() +
        '\n';

    //String message1 = "";
    //String message2 = "";
    String message1 = eicIqamah.bannerLine1 ?? "";
    String message2 = eicIqamah.bannerLine2 ?? "";

    var objDateLabel = Text(dateLabel);
    var objMessage1 = Text(message1,
        style: TextStyle(
            fontSize: 12,
            color: Color.fromARGB(255, 1, 56, 25).withOpacity(0.8)));
    var objMessage2 = Text(message2,
        style: TextStyle(
            fontSize: 12,
            color: Color.fromARGB(255, 1, 56, 25).withOpacity(0.8)));
    var textButton = TextButton.icon(
      onPressed: () {
        _launchURL('https://www.eicsanjose.org/wp/donations');
      },
      style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.all<Color>(Color.fromARGB(255, 3, 82, 6))),
      icon: Icon(Icons.paypal, size: 18),
      label: Text("Donate"),
    );
    var title = (eicIqamah.dateInput != null)
        ? 'EIC Iqamah ${eicIqamah.dateInput}'
        : 'EIC Iqamah';
    return Scaffold(
      body: _loaded
          ? Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: SafeArea(
                  minimum: const EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                flex: 6,
                                child: Container(
                                    //color: Colors.green,
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    objDateLabel,
                                    objMessage1,
                                    objMessage2
                                  ],
                                ))),
                            //Expanded(flex: 2, child: Container()),
                            Expanded(
                                flex: 2,
                                //child: Positioned(
                                child: Column(children: [
                                  CircleAvatar(
                                      radius: (52),
                                      backgroundColor:
                                          Color.fromARGB(255, 4, 84, 4),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.asset(
                                            "assets/images/eic_logo_1024.png"),
                                      )),
                                  textButton
                                ])),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              //child: buildCard4('Fajr', '6:00', '5:37', '640'),
                              child: buildCard4('Fajr الفجر', eicIqamah.fajr,
                                  eicIqamah.fajrStart, eicIqamah.fajrStop),
                            ),
                            Expanded(
                              flex: 4,
                              child: buildCard4('Dhur الظهر', eicIqamah.duhr,
                                  eicIqamah.duhrStart, eicIqamah.duhrStop),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              //child: buildCard4('Fajr', '6:00', '5:37', '640'),
                              child: buildCard4('Asr العصر', eicIqamah.asr,
                                  eicIqamah.asrStart, eicIqamah.asrStop),
                            ),
                            Expanded(
                              flex: 4,
                              child: buildCard4(
                                  'Maghrib المغرب',
                                  eicIqamah.maghrib,
                                  eicIqamah.maghribStart,
                                  eicIqamah.maghribStop),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              //child: buildCard4('Fajr', '6:00', '5:37', '640'),
                              child: buildCard4('Isha العشاء', eicIqamah.isha,
                                  eicIqamah.ishaStart, eicIqamah.ishaStop),
                            ),
                            Expanded(
                              flex: 4,
                              child: buildJummahCard(eicIqamah),
                            )
                          ],
                        ),
                        //
                        Expanded(
                            child: ListView.builder(
                                itemCount: eventsCount,
                                itemBuilder:
                                    (BuildContext context, int position) {
                                  return getNewsRows(eicIqamah, position);
                                }))
                        //
                      ])))
          : new Center(
              child: new CircularProgressIndicator(),
            ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 25, 114, 0),
        title: Text(title),
        actions: _getActionButtons(context),
      ),
    );
  }
}

Widget getNewsRows(EICIqamah eicIqamah, int position) {
  return GestureDetector(
      onTap: () {
        print('Clicked news item');
        _launchURL('https://www.eicsanjose.org/wp');
      },
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: ListTile(
              leading: Icon(
                Icons.event_available_rounded,
                color: Color.fromARGB(255, 1, 107, 5),
              ), //FlutterLogo(size: 72.0),
              title: Text(eicIqamah.events![position]),
              //subtitle: Text(eicIqamah.events![position]),
              //isThreeLine: true,
            ),
          )
        ],
      ));
}

Future<void> _launchURL(String url) async {
  if (!await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

Container buildCard4(String prayerName, prayerTime, startTime, endTime) {
  return Container(
      height: 120,
      width: 155,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(
                prayerName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                prayerTime,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7), fontSize: 24),
              ),
            ),
            Text(
              'Start: ' + startTime + ' - End: ' + endTime,
              style:
                  TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      ));
}

Container buildJummahCard(EICIqamah eicIqamah) {
  String jummahTime = eicIqamah.jummah1! +
      ': ' +
      eicIqamah.jummahKhateeb1! +
      //'Mufti Rohilullah' +
      '\n' +
      eicIqamah.jummah2! +
      ': ' +
      eicIqamah.jummahKhateeb2! +
      //'Hafiz Khan' +
      '\n';
  String? jummah3 = eicIqamah.jummah3;
  if (jummah3 != null && jummah3.length > 0) {
    jummahTime =
        jummahTime + eicIqamah.jummah3! + ': ' + eicIqamah.jummahKhateeb3!;
  }

  return Container(
      height: 120,
      width: 155,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Jumu\'ah الجمعة',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                jummahTime,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7), fontSize: 14),
              ),
            ),
          ],
        ),
      ));
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}
