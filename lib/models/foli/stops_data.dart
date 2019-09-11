import 'dart:async';
import 'dart:convert';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/http_helper/useragent_client.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart';

Future<List<BusStop>> fetchStopData() async {
  final Client innerClient = Client();
  final UserAgentClient client =
      UserAgentClient(StaticValues.userAgent, innerClient);

  final response = await client.get(StaticValues.stopDataApiUrl);

  print('fetchStopData');
  innerClient?.close();
  client?.close();
  return compute(parseStopData, response.body);
}

List<BusStop> parseStopData(String responseBody) {
  final Map<String, dynamic> decoded = json.decode(responseBody);
  return decoded.values.map<BusStop>((json) => BusStop.fromJson(json)).toList();
}

class BusStop {
  BusStop({
    this.busStopCode,
    this.stopName,
    this.stopLgn,
    this.customName,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) => BusStop(
        busStopCode: json['stop_code'],
        stopName: json['stop_name'],
        customName: json['custom_Name'],
        stopLgn: LatLng(json['stop_lat']?.toDouble() ?? 0,
            json['stop_lon']?.toDouble() ?? 0),
      );

  String busStopCode;
  String stopName;
  String customName;
  LatLng stopLgn;

  Map<String, dynamic> toJson() => {
        'stop_code': busStopCode,
        'stop_name': stopName,
        'custom_Name': customName,
      };

  @override
  String toString() {
    return 'BusStop{busStopCode: $busStopCode, stopName: $stopName, customName: $customName, stopLgn: $stopLgn}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusStop &&
          runtimeType == other.runtimeType &&
          busStopCode == other.busStopCode;

  @override
  int get hashCode => busStopCode.hashCode;
}
