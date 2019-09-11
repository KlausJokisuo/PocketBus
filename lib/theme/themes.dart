import 'package:flutter/material.dart';

List<ThemeData> availableThemes = [lightTheme, darkTheme, blackTheme];

ThemeData lightTheme = ThemeData(
    fontFamily: 'Montserrat',
    textTheme: const TextTheme(body1: TextStyle(color: Colors.black)),
    brightness: Brightness.light,
    primaryColor: Colors.white,
    cardColor: Colors.white.withOpacity(0.99),
    buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
    iconTheme: const IconThemeData(color: Colors.orange),
    accentIconTheme: const IconThemeData(color: Colors.black),
    dialogBackgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    bottomAppBarColor: Colors.white.withOpacity(0.9),
    accentColor: Colors.orange);

ThemeData darkTheme = ThemeData(
    fontFamily: 'Montserrat',
    textTheme: const TextTheme(body1: TextStyle(color: Colors.white)),
    brightness: Brightness.dark,
    primaryColor: const Color(0x003a4256).withOpacity(1.0),
    cardColor: const Color(0x00404b60).withOpacity(0.9),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: const IconThemeData(color: Colors.orange),
    accentIconTheme: const IconThemeData(color: Colors.black),
    dialogBackgroundColor: const Color(0x003a4256).withOpacity(1.0),
    scaffoldBackgroundColor: const Color(0x003a4256).withOpacity(1.0),
    bottomAppBarColor: const Color(0x003a4256).withOpacity(0.95),
    accentColor: Colors.orange);

ThemeData blackTheme = ThemeData(
    fontFamily: 'Montserrat',
    textTheme: const TextTheme(body1: TextStyle(color: Colors.white)),
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    cardColor: Colors.black,
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: const IconThemeData(color: Colors.orange),
    accentIconTheme: const IconThemeData(color: Colors.black),
    dialogBackgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    bottomAppBarColor: Colors.black.withOpacity(0.80),
    accentColor: Colors.orange);
