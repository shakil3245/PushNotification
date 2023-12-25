import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
class MassageControlller {
// THIS FUCNTION REQUEST FOR FIREBASE MASSAGE PERMISSION TO DEVICE
  void requestMassagePermission() async {
    FirebaseMessaging massaging = FirebaseMessaging.instance;
    NotificationSettings settings = await massaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User Granted Permission!');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User Granted provisional permission!");
    } else {
      print('User Declined or has not accept permission!');
    }
  }

  //THIS FUNCTION HELPS TO GET DEVICE TOKEN
  String? mToken = '';
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      mToken = token;
      print("Android Device token is $mToken");
      saveToken(mToken!);
    });
  }

  //THIS FUNCTION SEND THE TOKEN FIREBASE FIRESTORE AND SAVE THERE
  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection('UserTokens').doc('User1').set({
      'token': token,
    });
  }

  //THERE WE INITIALIZED OUR ANDROID AND IOS SETTINGS AND LITESNING MASSAGE FROM FIREBASE
  //THIS IS FOR APP ON FORE GROUND
  initInfo() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      try {
        if (payload != null) {}
      } catch (e) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Massage-------------");
      print(
          "OnMassage: ${message.notification?.title}/${message.notification?.body}");
    // THIS SHOW MESSSAGE IN TOP OF APP
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContent: true,
      );

      AndroidNotificationDetails androidplatformChannelSpecifics =
          AndroidNotificationDetails('dbfood', 'dbfood',
              importance: Importance.max,
              styleInformation: bigTextStyleInformation,
              priority: Priority.max,
              playSound: false);

      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidplatformChannelSpecifics,);
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title, message.notification?.body, platformChannelSpecifics,
      payload: message.data['body']);
    });
  }

  Future<void> firebaseMessagingBackgroundHandeler (RemoteMessage message)async{
  print('Handeling a background message ${message.messageId}');
  }

//THIS FUCNTION HELP TO POST INFORMATION INTO FIREBASE CONSOLE
  void sendPushMessage(String token, String body, String title)async{
    try{
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String,String>{
            'Content-Type':'application/json',
          'Authorization':'key = AAAAoKrmFPM:APA91bG9pbY6KkAVteN_y3ZZexy5xkhqMAq1h_aFSiHzyfEQDRuEx3tcDp6Ln7WCskatXVhf7rz7FpDMPEyzjKV_e2lc75G96IvzwCk9CgGplp0OTFDd7jBs1BcJpcw2ownKAhti3Arw',
        },
        body: jsonEncode(<String,dynamic>{
        //TO TO NEW PAGE , WE NEED THIS JSON CODE PORTION
          'priority': 'high',
          'data':<String,dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status':'done',
            'body':body,
            'title':title,
          },
          //TO GET ONLY NOTIFICATION ON TOP , THIS PORTION IS HELP TO GET ONLY NOTIFICATION
          "notification":<String,dynamic>{
            'title': title,
            'body': body,
            "android_channel_id":"dbfood",
          },
          'to':token,

        },
        ),
      );

    }catch(e){
        if(kDebugMode){
          print("error push notification");
        }
    }
  }


// ******** PEST THIS THREE META DATA TO ANDROID MENIFEST *****

  // <meta-data
  // android:name="com.google.firebase.messaging.default_notification_channel_id"
  // android:value="default_notification_channel_id" />

  // <intent-filter>
  // <action android:name="FLUTTER_NOTIFICATION_CLICK" />
  // <category android:name="android.intent.category.LAUNCHER" />
  // </intent-filter>

  // <intent-filter>
  // <action android:name="com.google.firebase.MESSAGING_EVENT" />
  // </intent-filter>






}
