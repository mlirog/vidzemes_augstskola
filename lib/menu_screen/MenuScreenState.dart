import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidzemes_augstskola/lecture_graph/lecture_graph/Lecture_graph.dart';
import 'package:vidzemes_augstskola/webview/WebViewPage.dart';
import 'package:vidzemes_augstskola/functions/networkListener.dart';

import '../custom_icons.dart';
import '../main.dart';
import 'StaggeredGridViewBuilder.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class MenuScreenState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    firebaseTrigger(context);

    //listen to netwoek changes
    trackNetworkStatus(context);
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  void firebaseTrigger(BuildContext ctx) async {
    _firebaseMessaging.configure(
      onMessage: (message){
        print("onMessage msg: $message");
        showMessage(message);
      },

      onLaunch: (message){
        print("onLaunch msg: $message");
        showMessage(message);
      },
      onBackgroundMessage: (message){
        showMessage(message);
      },
      onResume: (message){
        print("onResume msg: $message");
        showMessage(message);

        if(message['data']['url'] != null ){
          //open webview with URL
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewPage(url: message['url'])),
          );
        }else if(message['data']['date'] != null){
          //open Lectures with Date
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Lecture_graph()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      bottomSheet: BottomAppBar(
        color: Color.fromRGBO(132, 173, 71, 0.8),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 80,
            top: 0,
            right: 80,
            bottom: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //facebook
              IconButton(
                icon: Icon(
                  CustomIcons.facebook,
                  color: Colors.white,
                ),
                onPressed: () {
                  _launchURL("fb://page/116748041732747");
                },
              ),
              //instagram
              IconButton(
                icon: Icon(
                  CustomIcons.instagram,
                  color: Colors.white,
                ),
                onPressed: () {
                  _launchURL(
                      "https://www.instagram.com/_u/vidzemes.augstskola/");
                },
              ),
              //youtube
              IconButton(
                icon: Icon(
                  CustomIcons.youtube,
                  color: Colors.white,
                ),
                onPressed: () {
                  _launchURL(
                      "https://www.youtube.com/channel/UCfAWUH0FjQnG-u3dyfeKvGQ");
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/menu.jpg"), fit: BoxFit.cover)),
          child: StreamBuilder<QuerySnapshot>(
              // ignore: deprecated_member_use
              stream: Firestore.instance
                  .collection('cards')
                  .orderBy("order_number")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return new Text('Error: ${snapshot.error}}');
                } else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        Expanded(
                            child:
                                Center(child: const CircularProgressIndicator())),
                      ],
                    );
                  } else {
                    return StaggeredGridViewBuilder(context, snapshot);
                  }
                }
              }),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _launchURL(url) async {
    print("Opening social media with url: $url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

Future<void> showMessage(message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'global_notifications', 'Global notifications', 'Peopele in this channel will recieve notifications meant for everyone',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'app_icon',
      ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      0, message['data']['click_action'], message['data']['text'], platformChannelSpecifics,
      payload: 'item x');
}