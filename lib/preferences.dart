import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final Preferences preferences = Preferences();

class Preferences {
  factory Preferences() {
    return _preferences;
  }

  Preferences._internal();

  static final Preferences _preferences = Preferences._internal();

  Future<bool> saveData(String dataKey, String data) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(dataKey, data);
  }

  Future<String> loadData(String dataKey) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(dataKey);
  }

  Future<bool> clearAllData() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }
}
