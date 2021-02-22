import 'dart:ui';

import 'package:flutter/material.dart';

const Color ViAOrange = Color(0xFFF15A22);

const Color ViAGreen = Color(0xFF84AD47);

const Color ViABlack = Color(0xFF313032);

const Map<int, Color> colorCodesGreen = {
  50: Color.fromRGBO(132, 173, 71, .1),
  100: Color.fromRGBO(132, 173, 71, .2),
  200: Color.fromRGBO(132, 173, 71, .3),
  300: Color.fromRGBO(132, 173, 71, .4),
  400: Color.fromRGBO(132, 173, 71, .5),
  500: Color.fromRGBO(132, 173, 71, .6),
  600: Color.fromRGBO(132, 173, 71, .7),
  700: Color.fromRGBO(132, 173, 71, .8),
  800: Color.fromRGBO(132, 173, 71, .9),
  900: Color.fromRGBO(132, 173, 71, 1),
};

const Map<int, Color> colorCodesOrange = {
  50: Color.fromRGBO(241, 90, 34, .1),
  100: Color.fromRGBO(241, 90, 34, .2),
  200: Color.fromRGBO(241, 90, 34, .3),
  300: Color.fromRGBO(241, 90, 34, .4),
  400: Color.fromRGBO(241, 90, 34, .5),
  500: Color.fromRGBO(241, 90, 34, .6),
  600: Color.fromRGBO(241, 90, 34, .7),
  700: Color.fromRGBO(241, 90, 34, .8),
  800: Color.fromRGBO(241, 90, 34, .9),
  900: Color.fromRGBO(241, 90, 34, 1),
};

const Map<int, Color> colorCodesBlack = {
  50: Color.fromRGBO(49, 48, 50, .1),
  100: Color.fromRGBO(49, 48, 50, .2),
  200: Color.fromRGBO(49, 48, 50, .3),
  300: Color.fromRGBO(49, 48, 50, .4),
  400: Color.fromRGBO(49, 48, 50, .5),
  500: Color.fromRGBO(49, 48, 50, .6),
  600: Color.fromRGBO(49, 48, 50, .7),
  700: Color.fromRGBO(49, 48, 50, .8),
  800: Color.fromRGBO(49, 48, 50, .9),
  900: Color.fromRGBO(49, 48, 50, 1),
};

const MaterialColor viaGreenMaterialColor = MaterialColor(0xff84AD47, colorCodesGreen);

const MaterialColor viaOrangeMaterialColor = MaterialColor(0xffF15A22, colorCodesGreen);

const MaterialColor viaBlackMaterialColor = MaterialColor(0xff313032, colorCodesGreen);
