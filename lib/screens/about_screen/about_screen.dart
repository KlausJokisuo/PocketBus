import 'package:pocket_bus/Screens/about_screen/contact_tile.dart';
import 'package:pocket_bus/Screens/about_screen/privacy_tile.dart';
import 'package:pocket_bus/Screens/about_screen/licenses_tile.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//    final Localization _localization = Localization();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 2.0,
          title: Text(Localization.of(context).aboutSettingsTitle),
        ),
        body: ListView(children: const <Widget>[
//          const SourceSettings(), Disabled until Code is cleaned Properly
          ContactTile(),
          PrivacyTile(),
          LicensesTile(),
        ]));
  }
}
