
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'StaggeredGridViewBuilder.dart';

class MenuScreenState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
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
                IconButton(icon: Icon(Icons.info_outline, color: Colors.white,), onPressed: () {
                  _launchURL("fb://page/116748041732747");
                },),
                //instagram
                IconButton(icon: Icon(Icons.info_outline, color: Colors.white,), onPressed: () {
                  _launchURL("https://www.instagram.com/_u/vidzemes.augstskola/");
                },),
                //youtube
                IconButton(icon: Icon(Icons.info_outline, color: Colors.white,), onPressed: () {
                  _launchURL("https://www.youtube.com/channel/UCfAWUH0FjQnG-u3dyfeKvGQ");
                },),
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
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) return new Text('Error: ${snapshot.error}');

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Expanded(child: Center(child: const CircularProgressIndicator()));
                    default:
                      return StaggeredGridViewBuilder(context, snapshot);
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
