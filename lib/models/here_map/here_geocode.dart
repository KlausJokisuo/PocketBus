import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String geocodeApiUrlBuilder({
  @required String locationId,
  @required String appId,
  @required String appCode,
}) {
  const String geoCodeApi =
      'https://geocoder.api.here.com/6.2/geocode.json?jsonattributes=1&gen=9&';

  final String _locationId =
      locationId == null ? '' : 'locationid=$locationId&';
  final String _appId = appId == null ? '' : 'app_id=$appId&';
  final String _appCode = appCode == null ? '' : 'app_code=$appCode';

  return (geoCodeApi + _locationId + _appId + _appCode).trim();
}

Future<HereGeocode> fetchGeocodeData({
  @required String locationId,
  @required String appId,
  @required String appCode,
}) async {
  assert(locationId != null);
  assert(appId != null);
  assert(appCode != null);

  final response = await http.get(geocodeApiUrlBuilder(
    locationId: locationId,
    appId: appId,
    appCode: appCode,
  ));

  print('fetchGeocodeData');
  return compute(parseData, response.body);
}

HereGeocode parseData(String responseBody) {
  final jsonData = json.decode(responseBody);
  return HereGeocode.fromJson(jsonData);
}

class HereGeocode {
  HereGeocode({
    this.response,
  });

  factory HereGeocode.fromJson(Map<String, dynamic> json) => HereGeocode(
        response: Response.fromJson(json['response']),
      );

  Response response;

  @override
  String toString() {
    return 'HereGeocode{response: $response}';
  }
}

class Response {
  Response({
    this.metaInfo,
    this.view,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        metaInfo: MetaInfo.fromJson(json['metaInfo']),
        view: json['view'] == null
            ? null
            : List<View>.from(json['view'].map((x) => View.fromJson(x))),
      );

  MetaInfo metaInfo;
  List<View> view;

  @override
  String toString() {
    return 'Response{metaInfo: $metaInfo, view: $view}';
  }
}

class MetaInfo {
  MetaInfo({
    this.timestamp,
  });

  factory MetaInfo.fromJson(Map<String, dynamic> json) => MetaInfo(
        timestamp: json['timestamp'],
      );

  String timestamp;

  @override
  String toString() {
    return 'MetaInfo{timestamp: $timestamp}';
  }
}

class View {
  View({
    this.place,
    this.viewId,
  });

  factory View.fromJson(Map<String, dynamic> json) => View(
        place: json['result'] == null
            ? null
            : List<Place>.from(json['result'].map((x) => Place.fromJson(x))),
        viewId: json['viewId'],
      );

  List<Place> place;
  int viewId;
}

class Place {
  Place({
    this.relevance,
    this.matchLevel,
    this.matchType,
    this.location,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        relevance: json['relevance'],
        matchLevel: json['matchLevel'],
        matchType: json['matchType'],
        location: Location.fromJson(json['location']),
      );
  double relevance;
  String matchLevel;
  String matchType;
  Location location;

  @override
  String toString() {
    return 'Result{relevance: $relevance, matchLevel: $matchLevel, matchType: $matchType, location: $location}';
  }
}

class Location {
  Location({
    this.locationId,
    this.locationType,
    this.position,
    this.navigationPosition,
    this.mapView,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        locationId: json['locationId'],
        locationType: json['locationType'],
        position: Position.fromJson(json['displayPosition']),
        navigationPosition: json['navigationPosition'] == null
            ? null
            : List<Position>.from(
                json['navigationPosition'].map((x) => Position.fromJson(x))),
        mapView: MapView.fromJson(json['mapView']),
        address: Address.fromJson(json['address']),
      );

  String locationId;
  String locationType;
  Position position;
  List<Position> navigationPosition;
  MapView mapView;
  Address address;

  @override
  String toString() {
    return 'Location{locationId: $locationId, locationType: $locationType, displayPosition: $position, navigationPosition: $navigationPosition, mapView: $mapView, address: $address}';
  }
}

class Address {
  Address({
    this.label,
    this.country,
    this.state,
    this.county,
    this.city,
    this.district,
    this.street,
    this.houseNumber,
    this.postalCode,
    this.additionalData,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        label: json['label'],
        country: json['country'],
        state: json['state'],
        county: json['county'],
        city: json['city'],
        district: json['district'],
        street: json['street'],
        houseNumber: json['houseNumber'],
        postalCode: json['postalCode'],
        additionalData: json['additionalData'] == null
            ? null
            : List<AdditionalDatum>.from(
                json['additionalData'].map((x) => AdditionalDatum.fromJson(x))),
      );

  String label;
  String country;
  String state;
  String county;
  String city;
  String district;
  String street;
  String houseNumber;
  String postalCode;
  List<AdditionalDatum> additionalData;

  @override
  String toString() {
    return 'Address{label: $label, country: $country, state: $state, county: $county, city: $city, district: $district, street: $street, houseNumber: $houseNumber, postalCode: $postalCode, additionalData: $additionalData}';
  }
}

class AdditionalDatum {
  AdditionalDatum({
    this.value,
    this.key,
  });

  factory AdditionalDatum.fromJson(Map<String, dynamic> json) =>
      AdditionalDatum(
        value: json['value'],
        key: json['key'],
      );

  String value;
  String key;

  @override
  String toString() {
    return 'AdditionalDatum{value: $value, key: $key}';
  }
}

class Position {
  Position({
    this.latitude,
    this.longitude,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble(),
      );

  double latitude;
  double longitude;

  @override
  String toString() {
    return 'DisplayPosition{latitude: $latitude, longitude: $longitude}';
  }
}

class MapView {
  MapView({
    this.topLeft,
    this.bottomRight,
  });

  factory MapView.fromJson(Map<String, dynamic> json) => MapView(
        topLeft: Position.fromJson(json['topLeft']),
        bottomRight: Position.fromJson(json['bottomRight']),
      );

  Position topLeft;
  Position bottomRight;

  @override
  String toString() {
    return 'MapView{topLeft: $topLeft, bottomRight: $bottomRight}';
  }
}
