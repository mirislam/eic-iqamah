import 'package:iqamah/main.dart';

import 'package:flutter/material.dart';
import '../models/eic_iqamah.dart';
import 'package:provider/provider.dart';
import '../providers/iqamah_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../utils/logger.dart';

class IqamahPage extends StatefulWidget {
  const IqamahPage({Key? key}) : super(key: key);

  @override
  State<IqamahPage> createState() => _IqamahPageState();
}

class _IqamahPageState extends State<IqamahPage> {
  late final FirebaseMessaging _messaging;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    logger.d('Call registerNotification');
    registerNotification();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('y-MM-dd').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IqamahProvider>(context, listen: false)
          .fetchIqamahData(formattedDate);
    });
  }

  _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, now.day);
    DateTime lastDate = firstDate.add(const Duration(days: 60));
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
              primary: const Color.fromARGB(255, 15, 84, 0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null && selected != selectedDate) {
      selectedDate = selected;
      String formattedDate = DateFormat('y-MM-dd').format(selected);
      logger.d("Selected formatted date $formattedDate");
      Provider.of<IqamahProvider>(context, listen: false)
          .fetchIqamahData(formattedDate);
    }
  }

  void registerNotification() async {
    logger.d("Step 2");
    _messaging = FirebaseMessaging.instance;

    logger.d("Step 3");

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('User granted permission');
      _messaging.getToken().then((token) async {
        logger.d('Token got:');
        logger.d(token);
        String platform = 'android';
        if (Platform.isIOS) {
          platform = 'iOS';
        }
        Map data = {
          "command": "register",
          "deviceToken": token,
          "platform": platform
        };
        await registerDeviceToEIC(data);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        logger.d('Got a message whilst in the foreground!');
        logger.d('Message data: ${message.data}');

        if (message.notification != null) {
          logger.d(
              'Message also contained a notification: ${message.notification}');
        }
      });
    } else {
      logger.w('User declined or has not accepted permission');
    }
  }

  Future<http.Response> registerDeviceToEIC(Map data) async {
    var url = 'https://www.eicsanjose.org/wp/fb_register.php';
    logger.d('Sending device registration to EICv$url: $data');

    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    logger.d("EIC Response: ${response.statusCode}");
    logger.d(response.body);
    return response;
  }

  List<Widget> _getActionButtons(BuildContext context, EICIqamah eicIqamah) {
    var notificationTexts = "";
    if (eicIqamah.notices != null) {
      for (var element in eicIqamah.notices!) {
        notificationTexts = notificationTexts + '\n' + element;
      }
    }

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
    List<Widget> buttons = [calIconButton];
    if (notificationTexts.length > 10) {
      buttons.add(notifyIconButton);
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IqamahProvider>(
      builder: (context, iqamahProvider, child) {
        final eicIqamah = iqamahProvider.eicIqamah;
        final isLoading = iqamahProvider.isLoading;

        DateFormat dateFormat = DateFormat("MMM dd, yyyy");
        String dateString = dateFormat.format(DateTime.now());

        String hijriMonth = eicIqamah.hijriMonth ?? '1';
        int hijriYear = eicIqamah.hijriYear ?? 1492;
        int hijriDay = eicIqamah.hijriDay ?? 1;

        int eventsCount = 0;
        List<String> tmpEvents = eicIqamah.events ?? [];
        eventsCount = tmpEvents.length;

        String dateLabel = dateString +
            '\n' +
            hijriMonth +
            '' +
            ' ' +
            hijriDay.toString() +
            ', ' +
            hijriYear.toString() +
            '\n';

        String message1 = eicIqamah.bannerLine1 ?? "";
        String message2 = eicIqamah.bannerLine2 ?? "";

        var objDateLabel = Text(dateLabel);
        var objMessage1 = Text(message1,
            style: TextStyle(
                fontSize: 12,
                color: const Color.fromARGB(255, 1, 56, 25)
                    .withValues(alpha: 0.8)));
        var objMessage2 = Text(message2,
            style: TextStyle(
                fontSize: 12,
                color: const Color.fromARGB(255, 1, 56, 25)
                    .withValues(alpha: 0.8)));
        var textButton = TextButton.icon(
          onPressed: () {
            _launchURL('https://www.eicsanjose.org/wp/donations');
          },
          style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 3, 82, 6))),
          icon: const Icon(Icons.paypal, size: 20),
          label: const Text("Donate", style: TextStyle(fontSize: 10)),
        );
        var title = (eicIqamah.dateInput != null)
            ? 'EIC Iqamah ${eicIqamah.dateInput}'
            : 'EIC Iqamah';

        return Scaffold(
          backgroundColor: Colors.white,
          drawer: const AppDrawer(),
          body: RefreshIndicator(
            onRefresh: () async {
              String formattedDate = DateFormat('y-MM-dd').format(selectedDate);
              await Provider.of<IqamahProvider>(context, listen: false)
                  .fetchIqamahData(formattedDate);
            },
            child: !isLoading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SafeArea(
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
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            objDateLabel,
                                            objMessage1,
                                            objMessage2
                                          ],
                                        ))),
                                    Expanded(
                                        flex: 2,
                                        child: Column(children: [
                                          CircleAvatar(
                                              radius: (52),
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 255, 255, 255),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.asset(
                                                    "assets/images/eic_logo_1024_transparent.png"),
                                              )),
                                          textButton
                                        ])),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: buildCard4(
                                          'Fajr الفجر',
                                          eicIqamah.fajr,
                                          eicIqamah.fajrStart,
                                          eicIqamah.fajrStop),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: buildCard4(
                                          'Dhur الظهر',
                                          eicIqamah.duhr,
                                          eicIqamah.duhrStart,
                                          eicIqamah.duhrStop),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: buildCard4(
                                          'Asr العصر',
                                          eicIqamah.asr,
                                          eicIqamah.asrStart,
                                          eicIqamah.asrStop),
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
                                      child: buildCard4(
                                          'Isha العشاء',
                                          eicIqamah.isha,
                                          eicIqamah.ishaStart,
                                          eicIqamah.ishaStop),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: buildJummahCard(eicIqamah),
                                    )
                                  ],
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: eventsCount,
                                    itemBuilder:
                                        (BuildContext context, int position) {
                                      return getNewsRows(eicIqamah, position);
                                    })
                              ]))
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color.fromARGB(255, 25, 114, 0),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            actions: _getActionButtons(context, eicIqamah),
          ),
        );
      },
    );
  }
}

Widget getNewsRows(EICIqamah eicIqamah, int position) {
  return GestureDetector(
      onTap: () {
        _launchURL('https://www.eicsanjose.org/wp');
      },
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: ListTile(
              leading: const Icon(
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

Widget buildCard4(String prayerName, prayerTime, startTime, endTime) {
  return SizedBox(
      height: 120,
      width: 155,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prayerName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color.fromARGB(255, 25, 114, 0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              prayerTime,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 24,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Start: $startTime - End: $endTime',
              style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.6), fontSize: 11),
            ),
          ],
        ),
      ));
}

Widget buildJummahCard(EICIqamah eicIqamah) {
  String jummahTime = '${eicIqamah.jummah1!}: ${eicIqamah.jummahKhateeb1!}\n'
      '${eicIqamah.jummah2!}: ${eicIqamah.jummahKhateeb2!}\n';
  String? jummah3 = eicIqamah.jummah3;
  if (jummah3 != null && jummah3.isNotEmpty) {
    jummahTime =
        '$jummahTime${eicIqamah.jummah3!}: ${eicIqamah.jummahKhateeb3!}';
  }

  return SizedBox(
      height: 120,
      width: 155,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Jumu\'ah الجمعة',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 25, 114, 0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                jummahTime,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.7), fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
