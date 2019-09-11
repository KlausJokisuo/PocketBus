import 'dart:convert';

import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/http_helper/useragent_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

Future<List<TripsData>> fetchTripsData(String tripRef) async {
  final Client innerClient = Client();
  final UserAgentClient client =
      UserAgentClient(StaticValues.userAgent, innerClient);

  final response = await client.get(StaticValues.tripsDataApiUrl + tripRef);
  print('fetchTripsData');
  innerClient?.close();
  client?.close();
  return compute(parseTripsData, response.body);
}

List<TripsData> parseTripsData(String responseBody) {
  final decoded = json.decode(responseBody);
  return decoded.map<TripsData>((json) => TripsData.fromJson(json)).toList();
}

class TripsData {
  TripsData({
    this.routeId,
    this.serviceId,
    this.tripHeadsign,
    this.directionId,
    this.blockId,
    this.shapeId,
    this.wheelchairAccessible,
  });

  factory TripsData.fromJson(Map<String, dynamic> json) => TripsData(
        routeId: json['route_id'],
        serviceId: json['service_id'],
        tripHeadsign: json['trip_headsign'],
        directionId: json['direction_id'],
        blockId: json['block_id'],
        shapeId: json['shape_id'],
        wheelchairAccessible: json['wheelchair_accessible'],
      );

  String routeId;
  String serviceId;
  String tripHeadsign;
  int directionId;
  String blockId;
  String shapeId;
  int wheelchairAccessible;

  @override
  String toString() {
    return 'TripsData{routeId: $routeId, serviceId: $serviceId, tripHeadsign: $tripHeadsign, directionId: $directionId, blockId: $blockId, shapeId: $shapeId, wheelchairAccessible: $wheelchairAccessible}';
  }
}
