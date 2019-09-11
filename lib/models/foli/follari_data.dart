import 'dart:convert';

import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/http_helper/useragent_client.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

Future<List<Rack>> fetchRackData() async {
  final Client innerClient = Client();
  final UserAgentClient client =
      UserAgentClient(StaticValues.userAgent, innerClient);

  final response = await client.get(StaticValues.follariDataApiUrl);
  print('fetchFollariData');
  innerClient?.close();
  client?.close();
  return compute(parseData, response.body);
}

List<Rack> parseData(String responseBody) {
  final jsonData = json.decode(responseBody);
  return RackData.fromJson(jsonData).racks.values.toList();
}

class RackData {
  RackData({
    this.racks,
  });

  factory RackData.fromJson(Map<String, dynamic> json) => RackData(
        racks: Map.from(json['racks'])
            .map((k, v) => MapEntry<String, Rack>(k, Rack.fromJson(v))),
      );

  Map<String, Rack> racks;
}

class Rack {
  Rack(
      {this.id,
      this.name,
      this.customName,
      this.lastSeen,
      this.rackLng,
      this.bikesAvail,
      this.slotsTotal,
      this.slotsAvail});

  factory Rack.fromJson(Map<String, dynamic> json) => Rack(
        id: json['id'],
        name: json['name'],
        customName: json['customName'],
        lastSeen: json['last_seen'] ?? json['last_seen'],
        rackLng: LatLng(json['lat'].toDouble(), json['lon'].toDouble()),
        bikesAvail: json['bikes_avail'],
        slotsTotal: json['slots_total'],
        slotsAvail: json['slots_avail'],
      );

  String id;
  String name;
  String customName;
  int lastSeen;
  LatLng rackLng;
  int bikesAvail;
  int slotsTotal;
  int slotsAvail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rack && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Rack{id: $id, name: $name, customName: $customName, lastSeen: $lastSeen, rackLng: $rackLng, bikesAvail: $bikesAvail, slotsTotal: $slotsTotal, slotsAvail: $slotsAvail}';
  }
}
