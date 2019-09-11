import 'dart:convert';

import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/http_helper/useragent_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

Future<List<ShapesData>> fetchShapesData(String shapeId) async {
  final Client innerClient = Client();
  final UserAgentClient client =
      UserAgentClient(StaticValues.userAgent, innerClient);

  final response = await client.get(StaticValues.shapesDataApiUrl + shapeId);
  print('fetchShapesData');
  innerClient?.close();
  client?.close();
  return compute(parseShapesData, response.body);
}

List<ShapesData> parseShapesData(String responseBody) {
  final decoded = json.decode(responseBody);
  return decoded.map<ShapesData>((json) => ShapesData.fromJson(json)).toList();
}

class ShapesData {
  ShapesData({
    this.lat,
    this.lon,
    this.traveled,
  });

  factory ShapesData.fromJson(Map<String, dynamic> json) => ShapesData(
        lat: json['lat'].toDouble(),
        lon: json['lon'].toDouble(),
        traveled: json['traveled'].toDouble(),
      );

  double lat;
  double lon;
  double traveled;

  @override
  String toString() {
    return 'ShapesData{lat: $lat, lon: $lon, traveled: $traveled}';
  }
}
