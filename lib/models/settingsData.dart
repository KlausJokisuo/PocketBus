import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkersToShow { BOTH, BUS, BIKE }
enum LocationToUse { CURRENT, TURKU }
enum ThemeToUse { LIGHT, DARK, BLACK }

class Settings {
  Settings({
    this.markersToShow,
    this.languageCode,
    this.themeToUse,
    this.mapType,
    this.locationToUse,
  }) {
    markersToShow ??= MarkersToShow.BOTH;
    locationToUse ??= LocationToUse.TURKU;
    themeToUse ??= ThemeToUse.DARK;
    mapType ??= MapType.normal;
    languageCode ??= '';
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      markersToShow: MarkersToShow.values[int.parse(
          json['markersToShow'] ?? MarkersToShow.BOTH.index.toString())],
      languageCode: json['language'] ?? '',
      themeToUse: ThemeToUse.values[
          int.parse(json['themeToUse'] ?? ThemeToUse.DARK.index.toString())],
      mapType: MapType.values[
          int.parse(json['mapType'] ?? MapType.normal.index.toString())],
      locationToUse: LocationToUse.values[int.parse(
          json['locationToUse'] ?? LocationToUse.CURRENT.index.toString())],
    );
  }

  MarkersToShow markersToShow;
  String languageCode;
  ThemeToUse themeToUse;
  MapType mapType;
  LocationToUse locationToUse;

  Map<String, dynamic> toJson() => {
        'markersToShow': markersToShow.index.toString(),
        'language': languageCode.toString(),
        'themeToUse': themeToUse.index.toString(),
        'mapType': mapType.index.toString(),
        'locationToUse': locationToUse.index.toString(),
      };

  @override
  String toString() {
    return 'Settings{markersToShow: $markersToShow, languageCode: $languageCode, themeToUse: $themeToUse, mapType: $mapType, locationToUse: $locationToUse}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          runtimeType == other.runtimeType &&
          markersToShow == other.markersToShow &&
          languageCode == other.languageCode &&
          themeToUse == other.themeToUse &&
          mapType == other.mapType &&
          locationToUse == other.locationToUse;

  @override
  int get hashCode =>
      markersToShow.hashCode ^
      languageCode.hashCode ^
      themeToUse.hashCode ^
      mapType.hashCode ^
      locationToUse.hashCode;
}
