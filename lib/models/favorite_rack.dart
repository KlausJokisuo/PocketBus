import 'dart:convert';

class FavoriteRack {
  FavoriteRack({
    this.rackId,
    this.customName,
  });

  factory FavoriteRack.fromJson(Map<String, dynamic> json) => FavoriteRack(
        rackId: json['rackId'],
        customName: json['customName'],
      );

  ///Rack identifier
  String rackId;
  String customName;

  Map<String, dynamic> toJson() => {
        'rackId': rackId,
        'customName': customName,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteRack &&
          runtimeType == other.runtimeType &&
          rackId == other.rackId;

  @override
  int get hashCode => rackId.hashCode;

  @override
  String toString() {
    return 'FavoriteRack{rackId: $rackId, customName: $customName}';
  }
}

List<FavoriteRack> favoriteRackFromJson(String str) {
  try {
    final jsonData = json.decode(str);
    return List<FavoriteRack>.from(
        jsonData.map((x) => FavoriteRack.fromJson(x)));
  } on NoSuchMethodError catch (_) {
    print('favoriteRackFromJson: Invalid Data');
    return [];
  }
}

String favoriteRackToJson(List<FavoriteRack> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}
