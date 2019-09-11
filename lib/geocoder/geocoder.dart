//Tries to use device geocoding first before moving to provider.
import 'package:pocket_bus/Models/here_map/here_geocode.dart';
import 'package:pocket_bus/Models/here_map/here_places_suggestions.dart';
import 'package:geolocator/geolocator.dart' as gl;

class Geocoder {
  Geocoder(this.suggestion, this.appId, this.appCode, this.addressLabel,
      [this.useDeviceGeocoder = true]);

  final Suggestion suggestion;
  final String appId;
  final String appCode;
  final String addressLabel;

  ///Tries to use Device geocoder (Geolocation plugin Android & iOS) and if it fails we use HERE geocoding service.
  final bool useDeviceGeocoder;

  Future<Position> geocode() async {
    if (useDeviceGeocoder) {
      print('Searching location via Device (Android / iOS) Geocoding');
      try {
        final List<gl.Placemark> location =
            await gl.Geolocator().placemarkFromAddress(addressLabel);
        return Position(
            latitude: location[0].position.latitude,
            longitude: location[0].position.longitude);
      } catch (e) {
        print('Unable to find location via Device Geocoding');
        print(e);
      }
    }

    print('Searching location via Provider (HERE) Geocoding');
    final HereGeocode hereGeocode = await fetchGeocodeData(
        appCode: appCode, appId: appId, locationId: suggestion.locationId);
    return hereGeocode.response.view[0].place[0].location.position;
  }
}
