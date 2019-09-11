import 'package:pocket_bus/Screens/about_screen/review_tile.dart';

import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';
import 'package:pocket_bus/screens/settings_screen/about_tile.dart';
import 'package:pocket_bus/screens/settings_screen/language_settings.dart';
import 'package:pocket_bus/screens/settings_screen/location_settings.dart';
import 'package:pocket_bus/screens/settings_screen/marker_settings.dart';
import 'package:pocket_bus/screens/settings_screen/notification_settings.dart';
import 'package:pocket_bus/screens/settings_screen/share_tile.dart';
import 'package:pocket_bus/screens/settings_screen/theme_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 2.0,
          title: Text(Localization.of(context).settingsTitle),
        ),
        body: ListView(children: <Widget>[
          Card(
            child: Column(
              children: const <Widget>[
                MarkerTile(),
                LocationTile(),
                ThemeTile(),
                NotificationSettings(),
                LanguageTile(),
              ],
            ),
          ),
          Card(
            child: Column(
              children: const <Widget>[ReviewTile(), ShareTile(), AboutTile()],
            ),
          ),
        ]));
  }
}
