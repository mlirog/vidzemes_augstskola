import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class noInternetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //if connection is back
    // Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   print("Network status changed to $result");
    //   if(result != ConnectivityResult.none) Navigator.pop(context);
    // });

    return Scaffold(
      body: InkWell(
        onTap: () async {
          //if user has connection, close warning
          if (await Connectivity().checkConnectivity() != ConnectivityResult.none) Navigator.pop(context);
        },
        child: Image.asset('assets/no_internet.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.center,),
      ),
    );
  }
}