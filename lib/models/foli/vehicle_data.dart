import 'dart:convert';

import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/http_helper/useragent_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

Future<VechilesData> fetchVehiclesData() async {
  final Client innerClient = Client();
  final UserAgentClient client =
      UserAgentClient(StaticValues.userAgent, innerClient);

  final response = await client.get(StaticValues.vehiclesDataApiUrl);

  print('fetchVehiclesData');
  innerClient?.close();
  client?.close();
  return compute(parseStopData, response.body);
}

VechilesData parseStopData(String responseBody) {
  final jsonData = json.decode(responseBody);
  return VechilesData.fromJson(jsonData);
}

class VechilesData {
  VechilesData({
    this.sys,
    this.status,
    this.servertime,
    this.result,
  });

  factory VechilesData.fromJson(Map<String, dynamic> json) => VechilesData(
        sys: json['sys'],
        status: json['status'],
        servertime: json['servertime'],
        result: Result.fromJson(json['result']),
      );
  String sys;
  String status;
  int servertime;
  Result result;
}

class Result {
  Result({
    this.responsetimestamp,
    this.producerref,
    this.responsemessageidentifier,
    this.status,
    this.moredata,
    this.vehicles,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      responsetimestamp: json['responsetimestamp'],
      producerref: json['producerref'],
      responsemessageidentifier: json['responsemessageidentifier'],
      status: json['status'],
      moredata: json['moredata'],
      vehicles: Map.from(json['vehicles'])
          .map((k, v) => MapEntry<String, Vehicle>(k, Vehicle.fromJson(v))));

  int responsetimestamp;
  String producerref;
  String responsemessageidentifier;
  bool status;
  bool moredata;

  Map<String, Vehicle> vehicles;
}

class Vehicle {
  Vehicle({
    this.recordedattime,
    this.validuntiltime,
    this.operatorref,
    this.monitored,
    this.incongestion,
    this.inpanic,
    this.vehicleref,
    this.linkdistance,
    this.percentage,
    this.lineref,
    this.directionref,
    this.publishedlinename,
    this.originref,
    this.originname,
    this.destinationref,
    this.destinationname,
    this.originaimeddeparturetime,
    this.destinationaimedarrivaltime,
    this.longitude,
    this.latitude,
    this.delay,
    this.blockref,
    this.previouscalls,
    this.nextStoppointref,
    this.nextVisitnumber,
    this.nextStoppointname,
    this.vehicleatstop,
    this.nextDestinationdisplay,
    this.nextAimedarrivaltime,
    this.nextExpectedarrivaltime,
    this.nextAimeddeparturetime,
    this.onwardcalls,
    this.tripref,
    this.delaysecs,
    this.nextExpecteddeparturetime,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        recordedattime: json['recordedattime'],
        validuntiltime: json['validuntiltime'],
        operatorref: json['operatorref'] ?? json['operatorref'],
        monitored: json['monitored'],
        incongestion: json['incongestion'],
        inpanic: json['inpanic'],
        vehicleref: json['vehicleref'],
        linkdistance: json['linkdistance'] ?? json['linkdistance'],
        percentage: json['percentage']?.toDouble(),
        lineref: json['lineref'] ?? json['lineref'],
        directionref: json['directionref'] ?? json['directionref'],
        publishedlinename:
            json['publishedlinename'] ?? json['publishedlinename'],
        originref: json['originref'] ?? json['originref'],
        originname: json['originname'] ?? json['originname'],
        destinationref: json['destinationref'] ?? json['destinationref'],
        destinationname: json['destinationname'] ?? json['destinationname'],
        originaimeddeparturetime: json['originaimeddeparturetime'] ??
            json['originaimeddeparturetime'],
        destinationaimedarrivaltime: json['destinationaimedarrivaltime'] ??
            json['destinationaimedarrivaltime'],
        longitude: json['longitude']?.toDouble(),
        latitude: json['latitude']?.toDouble(),
        delay: json['delay'] ?? json['delay'],
        blockref: json['blockref'] ?? json['blockref'],
        previouscalls: json['previouscalls'] == null
            ? null
            : List<Previouscall>.from(
                json['previouscalls'].map((x) => Previouscall.fromJson(x))),
        nextStoppointref:
            json['next_stoppointref'] ?? json['next_stoppointref'],
        nextVisitnumber: json['next_visitnumber'] ?? json['next_visitnumber'],
        nextStoppointname:
            json['next_stoppointname'] ?? json['next_stoppointname'],
        vehicleatstop: json['vehicleatstop'] ?? json['vehicleatstop'],
        nextDestinationdisplay:
            json['next_destinationdisplay'] ?? json['next_destinationdisplay'],
        nextAimedarrivaltime:
            json['next_aimedarrivaltime'] ?? json['next_aimedarrivaltime'],
        nextExpectedarrivaltime: json['next_expectedarrivaltime'] ??
            json['next_expectedarrivaltime'],
        nextAimeddeparturetime:
            json['next_aimeddeparturetime'] ?? json['next_aimeddeparturetime'],
        onwardcalls: json['onwardcalls'] == null
            ? null
            : List<Onwardcall>.from(
                json['onwardcalls'].map((x) => Onwardcall.fromJson(x))),
        tripref: json['__tripref'] ?? json['__tripref'],
        delaysecs: json['delaysecs'] ?? json['delaysecs'],
        nextExpecteddeparturetime: json['next_expecteddeparturetime'] ??
            json['next_expecteddeparturetime'],
      );

  int recordedattime;
  int validuntiltime;
  String operatorref;
  bool monitored;
  bool incongestion;
  bool inpanic;
  String vehicleref;
  int linkdistance;
  double percentage;
  String lineref;
  String directionref;
  String publishedlinename;
  String originref;
  String originname;
  String destinationref;
  String destinationname;
  int originaimeddeparturetime;
  int destinationaimedarrivaltime;
  double longitude;
  double latitude;
  String delay;
  String blockref;
  List<Previouscall> previouscalls;
  String nextStoppointref;
  int nextVisitnumber;
  String nextStoppointname;
  bool vehicleatstop;
  String nextDestinationdisplay;
  int nextAimedarrivaltime;
  int nextExpectedarrivaltime;
  int nextAimeddeparturetime;
  List<Onwardcall> onwardcalls;
  String tripref;
  int delaysecs;
  int nextExpecteddeparturetime;

  @override
  String toString() {
    return 'Vehicle{recordedattime: $recordedattime, validuntiltime: $validuntiltime, operatorref: $operatorref, monitored: $monitored, incongestion: $incongestion, inpanic: $inpanic, vehicleref: $vehicleref, linkdistance: $linkdistance, percentage: $percentage, lineref: $lineref, directionref: $directionref, publishedlinename: $publishedlinename, originref: $originref, originname: $originname, destinationref: $destinationref, destinationname: $destinationname, originaimeddeparturetime: $originaimeddeparturetime, destinationaimedarrivaltime: $destinationaimedarrivaltime, longitude: $longitude, latitude: $latitude, delay: $delay, blockref: $blockref, previouscalls: $previouscalls, nextStoppointref: $nextStoppointref, nextVisitnumber: $nextVisitnumber, nextStoppointname: $nextStoppointname, vehicleatstop: $vehicleatstop, nextDestinationdisplay: $nextDestinationdisplay, nextAimedarrivaltime: $nextAimedarrivaltime, nextExpectedarrivaltime: $nextExpectedarrivaltime, nextAimeddeparturetime: $nextAimeddeparturetime, onwardcalls: $onwardcalls, tripref: $tripref, delaysecs: $delaysecs, nextExpecteddeparturetime: $nextExpecteddeparturetime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          vehicleref == other.vehicleref;

  @override
  int get hashCode => vehicleref.hashCode;
}

class Onwardcall {
  Onwardcall({
    this.stoppointref,
    this.visitnumber,
    this.stoppointname,
    this.aimedarrivaltime,
    this.expectedarrivaltime,
    this.aimeddeparturetime,
    this.expecteddeparturetime,
  });

  factory Onwardcall.fromJson(Map<String, dynamic> json) => Onwardcall(
        stoppointref: json['stoppointref'],
        visitnumber: json['visitnumber'],
        stoppointname: json['stoppointname'],
        aimedarrivaltime: json['aimedarrivaltime'],
        expectedarrivaltime: json['expectedarrivaltime'],
        aimeddeparturetime: json['aimeddeparturetime'],
        expecteddeparturetime: json['expecteddeparturetime'],
      );

  String stoppointref;
  int visitnumber;
  String stoppointname;
  int aimedarrivaltime;
  int expectedarrivaltime;
  int aimeddeparturetime;
  int expecteddeparturetime;
}

class Previouscall {
  Previouscall({
    this.stoppointref,
    this.visitnumber,
    this.stoppointname,
    this.aimedarrivaltime,
    this.aimeddeparturetime,
  });

  factory Previouscall.fromJson(Map<String, dynamic> json) => Previouscall(
        stoppointref: json['stoppointref'],
        visitnumber: json['visitnumber'],
        stoppointname: json['stoppointname'],
        aimedarrivaltime: json['aimedarrivaltime'],
        aimeddeparturetime: json['aimeddeparturetime'],
      );

  String stoppointref;
  int visitnumber;
  String stoppointname;
  int aimedarrivaltime;
  int aimeddeparturetime;
}
