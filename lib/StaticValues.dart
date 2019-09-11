import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/here_map/here_geocode.dart';
import 'package:package_info/package_info.dart';

class StaticValues {
  const StaticValues();

  static String hereMapAppId;
  static String hereMapAppCode;

  static String appName;
  static String version;
  static String packageName;

  static const String pocketBusWebSite =
      'https://sites.google.com/view/pocketbus/';
  static const String gitHub = 'https://github.com/KlausJokinen/PocketBus';

  static const String authorEmail = 'klasudeveloper@gmail.com';
  static String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';

  static String userAgent =
      '${StaticValues.appName.replaceAll(' ', '')}/${StaticValues.version}; (Android/*; +${StaticValues.playStoreUrl}';

  static const String stopDataApiUrl = 'http://data.Foli.fi/gtfs/stops';
  static const String vehiclesDataApiUrl = 'http://data.foli.fi/siri/vm';
  static const String scheduleDataApiUrl =
      'http://data.Foli.fi/siri/sm/'; // + StopCode Ex T4
  static const String tripsDataApiUrl =
      'http://data.foli.fi/gtfs/trips/trip/'; // + tripref: (00013474__4662generatedBlock)
  static const String shapesDataApiUrl =
      'http://data.foli.fi/gtfs/shapes/'; // + shape_id (0_417)
  static const String follariDataApiUrl = 'http://data.Foli.fi/citybike';

  static const String foliRssFeedUrl = 'https://www.foli.fi/fi/rss.xml';

  static Position turkuLtng =
      Position(latitude: 60.451401, longitude: 22.266936); //Turku - Kauppatori

  static const int scheduleRefreshInterval = 50; // Seconds
  static const int busLocationRefreshInterval = 3; // Seconds

  static Future<void> init() async {
    // Reads keys from ./api.keys
    final Map<String, String> apiKeysMap = await readApiKeys('api.keys');

    hereMapAppId = apiKeysMap['hereMapAppId'];
    hereMapAppCode = apiKeysMap['hereMapAppCode'];

    readApiKeys(
      'api.keys',
    );

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    ///These settings must be changed to control app name
    ///iOS -- Info.plist <CFBundleDisplayName> -- <CFBundleName>
    ///Android -- AndroidManifest.xml -- android:label
    appName = packageInfo.appName;
    version = packageInfo.version;
    packageName = packageInfo.packageName;
  }
}
