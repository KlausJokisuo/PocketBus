import 'dart:async';
import 'dart:convert';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:pocket_bus/Models/settingsData.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocket_bus/preferences.dart';

class SettingsBloc implements BlocBase {
  Settings _settings = Settings();

  final BehaviorSubject<Settings> _settingsController =
      BehaviorSubject<Settings>();
  Sink<Settings> get _inSettings => _settingsController.sink;
  Stream<Settings> get outSettings => _settingsController.stream;

  @override
  void dispose() {
    _settingsController?.close();
  }

  Future<bool> _saveSettings() async {
    return preferences.saveData('_settings', json.encode(_settings.toJson()));
  }

  Future<void> loadSettings() async {
//    await preferences.clearAllData();
    try {
      _settings = Settings.fromJson(
          json.decode(await preferences.loadData('_settings')));

      debugPrint('Loaded settings ' + _settings.toString());

      _inSettings.add(Settings(
          markersToShow: _settings.markersToShow,
          locationToUse: _settings.locationToUse,
          mapType: _settings.mapType,
          themeToUse: _settings.themeToUse,
          languageCode: _settings.languageCode));
    } on NoSuchMethodError catch (e) {
      print('loadSettings: Invalid Settings Data');
      print(e.toString());
      _inSettings.add(Settings());
    }
  }

  void changeSetting(
      {MarkersToShow markersToShow,
      ThemeToUse themeToUse,
      MapType mapType,
      LocationToUse locationToUse,
      String languageCode,
      bool notifyListeners = true}) {
    _settings
      ..markersToShow = markersToShow ?? _settings.markersToShow
      ..themeToUse = themeToUse ?? _settings.themeToUse
      ..mapType = mapType ?? _settings.mapType
      ..locationToUse = locationToUse ?? _settings.locationToUse
      ..languageCode = languageCode ?? _settings.languageCode;

    _saveSettings();

    //Because we are using Distinct with Streams we need to create a new object and pass it to the Stream
    if (notifyListeners) {
      _inSettings.add(Settings(
          markersToShow: markersToShow ?? _settings.markersToShow,
          locationToUse: locationToUse ?? _settings.locationToUse,
          mapType: mapType ?? _settings.mapType,
          themeToUse: themeToUse ?? _settings.themeToUse,
          languageCode: languageCode ?? _settings.languageCode));
    }
  }
}
