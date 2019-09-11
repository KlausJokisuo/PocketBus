import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/pocketBus.dart';
import 'package:pocket_bus/licenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await StaticValues.init();
  generateLicenses();
  runApp(PocketBus());
}
