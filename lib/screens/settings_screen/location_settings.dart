import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/settingsData.dart';

import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class LocationTile extends StatelessWidget {
  const LocationTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final Map<LocationToUse, String> locationOptionsMap = {
      LocationToUse.CURRENT: Localization.of(context).locationOptionCurrent,
      LocationToUse.TURKU: Localization.of(context).locationOptionTurku,
    };
    return StreamBuilder<Settings>(
        stream: _settingsBloc.outSettings.distinct((previousValue, nextValue) =>
            previousValue.locationToUse == nextValue.locationToUse),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenterSpinner();
          }

          TapDownDetails tapDetails;
          return InkWell(
            onTapDown: (TapDownDetails details) => tapDetails = details,
            onTap: () {
              final Offset startOffset = offsetFromCoordinates(
                  tapDetails.globalPosition.dx,
                  tapDetails.globalPosition.dy,
                  context);
              return genericDialog(
                context,
                child: LocationOptions(
                  locationToUse: snapshot.data.locationToUse,
                ),
              );
            },
            child: GenericTile(
              title: Localization.of(context).locationSettingsTitle,
              subtitle: '${locationOptionsMap[snapshot.data.locationToUse]}',
              leadingWidget: const Icon(Icons.location_on),
            ),
          );
        });
  }
}

class LocationOptions extends StatelessWidget {
  const LocationOptions({Key key, @required this.locationToUse})
      : super(key: key);

  final LocationToUse locationToUse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: <Widget>[
          GenericDialogTitle(
            title: Localization.of(context).locationSettingsTitle,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CurrentLocationTile(locationToUse: locationToUse),
              TurkuLocationTile(locationToUse: locationToUse)
            ],
          ),
        ],
      ),
    );
  }
}

class CurrentLocationTile extends StatelessWidget {
  const CurrentLocationTile({Key key, @required this.locationToUse})
      : super(key: key);

  final LocationToUse locationToUse;

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      onTap: () {
        Navigator.pop(context);
        _settingsBloc.changeSetting(locationToUse: LocationToUse.CURRENT);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20.0, right: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Icon(Icons.location_searching),
            Text(Localization.of(context).locationOptionCurrent),
            locationToUse == LocationToUse.CURRENT
                ? const BouncyWidget(
                    child: Icon(
                      Icons.check,
                      size: 25,
                    ),
                    tweenBegin: 1.0,
                    tweenEnd: 1.3,
                    duration: Duration(milliseconds: 400),
                  )
                : const EmptyBox(
                    width: 25,
                  )
          ],
        ),
      ),
    );
  }
}

class TurkuLocationTile extends StatelessWidget {
  const TurkuLocationTile({Key key, @required this.locationToUse})
      : super(key: key);
  final LocationToUse locationToUse;

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      onTap: () {
        Navigator.pop(context);
        _settingsBloc.changeSetting(locationToUse: LocationToUse.TURKU);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20.0, right: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Icon(Icons.location_city),
            Text(Localization.of(context).locationOptionTurku),
            locationToUse == LocationToUse.TURKU
                ? const BouncyWidget(
                    child: Icon(
                      Icons.check,
                      size: 25,
                    ),
                    tweenBegin: 1.0,
                    tweenEnd: 1.3,
                    duration: Duration(milliseconds: 400),
                  )
                : const EmptyBox(
                    width: 25,
                  )
          ],
        ),
      ),
    );
  }
}
