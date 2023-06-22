import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:travellog/auth/loginpage.dart';
import 'package:travellog/pages/homepage.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true);
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.messageId);
}

showNotification(RemoteMessage message) async {
  Map<String, dynamic> data = jsonDecode(message.data['message']);
  log(data.toString());
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'channel', 'Chat messages',
          channelDescription: 'Chat messages will be received here',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          color: Colors.green,
          styleInformation: BigTextStyleInformation(
            '${data['fromCity']} to ${data['toCity']}\n${data['journeyDate']} ${data['time']}',
            contentTitle: data['mode'] == 'Cancel'
                ? 'Ticket Cancelled for ${data['name']}'
                : '${data['name']}',
          ));
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  FlutterLocalNotificationsPlugin().show(
    45452,
    data['mode'] == 'Cancel'
        ? 'Ticket cancelled fo ${data['name']} ${data['journeyDate']} ${data['time']}'
        : ' ${data['name']} ${data['journeyDate']} ${data['time']}',
    '${data['fromCity']} to ${data['toCity']}',
    platformChannelSpecifics,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      showNotification(message);
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  void updateFCM() async {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    log('$fcmToken has been added');
    var snapshot = await FirebaseFirestore.instance
        .collection("FcmToken")
        .where("email", isEqualTo: 'admin@gmail.com')
        .get();
    var docId = snapshot.docs.first.id;
    List fcmList = snapshot.docs.first.get('fcmTokens');
    if (fcmList.contains(fcmToken)) {
      return;
    } else {
      fcmList.add(fcmToken);
      FirebaseFirestore.instance
          .collection("FcmToken")
          .doc(docId)
          .update({'fcmTokens': fcmList});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (FirebaseAuth.instance.currentUser!.email == 'admin@gmail.com') {
              updateFCM();
            }
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
