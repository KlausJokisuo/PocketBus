import 'package:pocket_bus/here_places/here_places_autocomplete.dart';
import 'package:pocket_bus/Misc/custom_sheet.dart';
import 'package:pocket_bus/Screens/Sheets/favorite_screen.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocket_bus/screens/map_screens/main_map_screen/main_map_body.dart';

class MainMapFrame extends StatelessWidget {
  const MainMapFrame({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        resizeToAvoidBottomPadding: false,
        body: MainMapBody(),
        bottomNavigationBar: const BottomNavigationBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const FavoritesButton());
  }
}

class SearchButton extends StatefulWidget {
  const SearchButton({Key key}) : super(key: key);

  @override
  _SearchButtonState createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.search,
        size: 28,
      ),
      onPressed: () async {
        final GoogleMapController controller = await mainMapController.future;
        await HerePlacesAutocomplete.show(
                context: context,
                appId: StaticValues.hereMapAppId,
                appCode: StaticValues.hereMapAppCode,
                position: StaticValues.turkuLtng,
                country: 'fin',
                language: Localizations.localeOf(context).languageCode)
            .then((position) async {
          if (position != null) {
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 17.0,
                ),
              ),
            );
          }
        });
      },
    );
  }
}

class FavoritesButton extends StatelessWidget {
  const FavoritesButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        elevation: 4.0,
        child: const Icon(
          Icons.favorite,
        ),
        onPressed: () {
          showModalBottomSheetCustom(
              context: context,
              builder: (BuildContext context) => const FavoritesScreen());
        });
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.settings,
        size: 28,
      ),
      onPressed: () {
        return Navigator.pushNamed(context, '/settings');
      },
    );
  }
}

class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const <Widget>[
          SettingsButton(),
          SearchButton(),
        ],
      ),
    );
  }
}
