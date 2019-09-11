import 'dart:async';
import 'dart:convert';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/http_helper/useragent_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

Future<ScheduleData> fetchScheduleData(String currentStopCode) async {
  final Client innerClient = Client();
  final UserAgentClient client =
      UserAgentClient(StaticValues.userAgent, innerClient);

  final response =
      await client.get(StaticValues.scheduleDataApiUrl + currentStopCode);

  innerClient?.close();
  client?.close();
  return compute(parseScheduleData, response.body);
}

ScheduleData parseScheduleData(String responseBody) {
  final jsonData = json.decode(responseBody);
  return ScheduleData.fromJson(jsonData);
}

class ScheduleData {
  ScheduleData({
    this.sys,
    this.status,
    this.schedules,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) => ScheduleData(
        sys: json['sys'],
        status: json['status'],
        schedules: List<Schedule>.from(
            json['result'].map((x) => Schedule.fromJson(x))),
      );
  String sys;
  String status;
  List<Schedule> schedules;

  @override
  String toString() {
    return 'ScheduleData{sys: $sys, status: $status, schedules: $schedules}';
  }
}

class Schedule {
  Schedule(
      {this.recordedattime,
      this.lineref,
      this.dataframeref,
      this.datedvehiclejourneyref,
      this.directionname,
      this.originref,
      this.destinationref,
      this.originaimeddeparturetime,
      this.destinationaimedarrivaltime,
      this.monitored,
      this.incongestion,
      this.longitude,
      this.latitude,
      this.blockref,
      this.vehicleref,
      this.visitnumber,
      this.vehicleatstop,
      this.destinationdisplay,
      this.aimedarrivaltime,
      this.expectedarrivaltime,
      this.aimeddeparturetime,
      this.expecteddeparturetime,
      this.tripref});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        // Start of http://data.foli.fi/siri/sm/T4
        recordedattime: json['recordedattime'],
        lineref: json['lineref'],
        dataframeref: json['dataframeref'],
        datedvehiclejourneyref: json['datedvehiclejourneyref'],
        directionname: json['directionname'],
        originref: json['originref'],
        destinationref: json['destinationref'],
        originaimeddeparturetime: json['originaimeddeparturetime'],
        destinationaimedarrivaltime: json['destinationaimedarrivaltime'],
        monitored: json['monitored'],
        incongestion: json['incongestion'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        blockref: json['blockref'],
        vehicleref: json['vehicleref'],
        visitnumber: json['visitnumber'],
        vehicleatstop: json['vehicleatstop'],
        destinationdisplay: json['destinationdisplay'],
        aimedarrivaltime: json['aimedarrivaltime'],
        expectedarrivaltime: json['expectedarrivaltime'],
        aimeddeparturetime: json['aimeddeparturetime'],
        expecteddeparturetime: json['expecteddeparturetime'],
        tripref: json['__tripref'],
        // End of of http://data.foli.fi/siri/sm/T4
      );

  int recordedattime;
  String lineref;
  String dataframeref;
  String datedvehiclejourneyref;
  String directionname;
  String originref;
  String destinationref;
  int originaimeddeparturetime;
  int destinationaimedarrivaltime;
  bool monitored;
  bool incongestion;
  double longitude;
  double latitude;
  String blockref;
  String vehicleref;
  int visitnumber;
  bool vehicleatstop;
  String destinationdisplay;
  int aimedarrivaltime;
  int expectedarrivaltime;
  int aimeddeparturetime;
  int expecteddeparturetime;
  String tripref;

  Map<String, dynamic> toJson() => {
        'recordedattime': recordedattime,
        'lineref': lineref,
        'datedvehiclejourneyref': datedvehiclejourneyref,
        'directionname': directionname,
        'originref': originref,
        'destinationref': destinationref,
        'originaimeddeparturetime': originaimeddeparturetime,
        'destinationaimedarrivaltime': destinationaimedarrivaltime,
        'monitored': monitored,
        'incongestion': incongestion,
        'longitude': longitude ?? longitude,
        'latitude': latitude ?? latitude,
        'blockref': blockref,
        'vehicleref': vehicleref,
        'visitnumber': visitnumber,
        'vehicleatstop': vehicleatstop,
        'aimedarrivaltime': aimedarrivaltime,
        'expectedarrivaltime': expectedarrivaltime,
        'aimeddeparturetime': aimeddeparturetime,
        'expecteddeparturetime': expecteddeparturetime,
        '__tripref': tripref,
      };

  @override
  String toString() {
    return 'Schedule{recordedattime: $recordedattime, lineref: $lineref, dataframeref: $dataframeref, datedvehiclejourneyref: $datedvehiclejourneyref, directionname: $directionname, originref: $originref, destinationref: $destinationref, originaimeddeparturetime: $originaimeddeparturetime, destinationaimedarrivaltime: $destinationaimedarrivaltime, monitored: $monitored, incongestion: $incongestion, longitude: $longitude, latitude: $latitude, blockref: $blockref, vehicleref: $vehicleref, visitnumber: $visitnumber, vehicleatstop: $vehicleatstop, destinationdisplay: $destinationdisplay, aimedarrivaltime: $aimedarrivaltime, expectedarrivaltime: $expectedarrivaltime, aimeddeparturetime: $aimeddeparturetime, expecteddeparturetime: $expecteddeparturetime, tripref: $tripref}';
  }
}
