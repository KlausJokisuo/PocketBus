import 'dart:convert';

class FavoriteStop {
  FavoriteStop({
    this.stopCode,
    this.customName,
  });

  factory FavoriteStop.fromJson(Map<String, dynamic> json) => FavoriteStop(
        stopCode: json['stopCode'],
        customName: json['customName'],
      );

  ///Stop identifier
  String stopCode;
  String customName;

  Map<String, dynamic> toJson() => {
        'stopCode': stopCode,
        'customName': customName,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteStop &&
          runtimeType == other.runtimeType &&
          stopCode == other.stopCode;

  @override
  int get hashCode => stopCode.hashCode;

  @override
  String toString() {
    return 'FavoriteStop{stopCode: $stopCode, customName: $customName}';
  }
}

List<FavoriteStop> favoriteStopFromJson(String str) {
  try {
    final jsonData = json.decode(str);
    return List<FavoriteStop>.from(
        jsonData.map((x) => FavoriteStop.fromJson(x)));
  } on NoSuchMethodError catch (_) {
    print('favoriteStopFromJson: Invalid Data');
    return [];
  }
}

String favoriteStopToJson(List<FavoriteStop> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}
