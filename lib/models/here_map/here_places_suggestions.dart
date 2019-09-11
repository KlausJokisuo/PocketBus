import 'dart:convert';

import 'package:pocket_bus/Models/here_map/here_geocode.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String suggestionApiUrlBuilder({
  @required String searchQuery,
  @required String appId,
  @required String appCode,
  Position position,
  String country,
  String language,
  int maxResults,
}) {
  const String suggestionsApi =
      'https://autocomplete.geocoder.api.here.com/6.2/suggest.json?';

  final String _query = searchQuery == null ? '' : 'query=$searchQuery&';
  final String _biasLocation = position == null
      ? ''
      : 'prox=${position.latitude},${position.longitude}&';

  final String _country = country == null ? '' : 'country=$country&';
  final String _language = language == null ? '' : 'language=$language&';
  final String _maxResult = maxResults == null ? '' : 'maxresults=$maxResults&';
  final String _appId = appId == null ? '' : 'app_id=$appId&';
  final String _appCode = appCode == null ? '' : 'app_code=$appCode';

  return (suggestionsApi +
          _query +
          _biasLocation +
          _country +
          _language +
          _appId +
          _maxResult +
          _appId +
          _appCode)
      .trim();
}

Future<HerePlacesSuggestions> fetchSuggestionsData({
  @required String searchQuery,
  @required String appId,
  @required String appCode,
  Position position,
  String country,
  String language,
  int maxResults,
}) async {
  assert(searchQuery != null);
  assert(appId != null);
  assert(appCode != null);

  final response = await http.get(suggestionApiUrlBuilder(
      searchQuery: searchQuery,
      appId: appId,
      appCode: appCode,
      position: position,
      country: country,
      language: language,
      maxResults: maxResults));

  print('fetchSuggestionsData');
  return compute(parseData, response.body);
}

HerePlacesSuggestions parseData(String responseBody) {
  final jsonData = json.decode(responseBody);
  return HerePlacesSuggestions.fromJson(jsonData);
}

class HerePlacesSuggestions {
  HerePlacesSuggestions({
    this.suggestions,
  });

  factory HerePlacesSuggestions.fromJson(Map<String, dynamic> json) =>
      HerePlacesSuggestions(
        suggestions: json['suggestions'] == null
            ? null
            : List<Suggestion>.from(
                json['suggestions'].map((x) => Suggestion.fromJson(x))),
      );

  List<Suggestion> suggestions;

  @override
  String toString() {
    return 'HerePlacesSuggestions{suggestions: $suggestions}';
  }
}

class Suggestion {
  Suggestion({
    this.label,
    this.language,
    this.countryCode,
    this.locationId,
    this.address,
    this.distance,
    this.matchLevel,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
        label: json['label'],
        language: json['language'],
        countryCode: json['countryCode'],
        locationId: json['locationId'],
        address: Address.fromJson(json['address']),
        distance: json['distance'],
        matchLevel: json['matchLevel'],
      );

  String label;
  String language;
  String countryCode;
  String locationId;
  Address address;
  int distance;
  String matchLevel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Suggestion &&
          runtimeType == other.runtimeType &&
          locationId == other.locationId;

  @override
  int get hashCode => locationId.hashCode;

  @override
  String toString() {
    return 'Suggestion{label: $label, language: $language, countryCode: $countryCode, locationId: $locationId, address: $address, distance: $distance, matchLevel: $matchLevel}';
  }
}

class Address {
  Address({
    this.country,
    this.state,
    this.county,
    this.city,
    this.district,
    this.street,
    this.houseNumber,
    this.unit,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        country: json['country'],
        state: json['state'],
        county: json['county'],
        city: json['city'],
        district: json['district'],
        street: json['street'],
        houseNumber: json['houseNumber'],
        unit: json['unit'],
        postalCode: json['postalCode'],
      );

  String country;
  String state;
  String county;
  String city;
  String district;
  String street;
  String houseNumber;
  String unit;
  String postalCode;

  @override
  String toString() {
    return 'Address{country: $country, state: $state, county: $county, city: $city, district: $district, street: $street, houseNumber: $houseNumber, unit: $unit, postalCode: $postalCode}';
  }
}
