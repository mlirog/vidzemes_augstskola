import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vidzemes_augstskola/no_internet/noInternetPage.dart';


void trackNetworkStatus(BuildContext ctx) {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    print("Network changed to $result");
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
    } else {
      Navigator.push(
        ctx,
        MaterialPageRoute(builder: (context) => noInternetPage()),
      );
    }
  });
}







//
//
//
// Future<void> listenNetworkChanges(BuildContext ctx) async {
//   //checks status on init
//   if(_hasNoInternet(await Connectivity().checkConnectivity())){
//     print("App has no internet upon a page startup");
//     showErrorPage(ctx);
//   }
//
//   //adds listener on connectivity change
//   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//     print("Network status changed to $result");
//     if(_hasNoInternet(result)) showErrorPage(ctx);
//   });
// }
//
// bool _hasNoInternet(ConnectivityResult result) {
//   switch(result){
//     case ConnectivityResult.wifi:
//     case ConnectivityResult.mobile:
//       return false;
//       break;
//     case ConnectivityResult.none:
//     default: return true;
//   }
// }
//
// void showErrorPage(BuildContext ctx) {
//   Navigator.push(
//     ctx,
//     MaterialPageRoute(builder: (context) => noInternetPage()),
//   );
// }