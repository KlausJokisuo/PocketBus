import 'package:pocket_bus/BloC/bloc_provider.dart';

import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/settingsData.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class MarkerTile extends StatelessWidget {
  const MarkerTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final Map<MarkersToShow, String> markerOptionsMap = {
      MarkersToShow.BOTH: Localization.of(context).markerOptionBoth,
      MarkersToShow.BIKE: Localization.of(context).markerOptionBike,
      MarkersToShow.BUS: Localization.of(context).markerOptionBus
    };
    return StreamBuilder<Settings>(
        stream: _settingsBloc.outSettings.distinct((previousValue, nextValue) =>
            previousValue.markersToShow == nextValue.markersToShow),
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
                child: MarkerOptions(
                  markersToShow: snapshot.data.markersToShow,
                ),
              );
            },
            child: GenericTile(
              title: Localization.of(context).markerSettingsTitle,
              subtitle: '${markerOptionsMap[snapshot.data.markersToShow]}',
              leadingWidget: const Icon(Icons.map),
            ),
          );
        });
  }
}

class MarkerOptions extends StatelessWidget {
  const MarkerOptions({Key key, @required this.markersToShow})
      : super(key: key);

  final MarkersToShow markersToShow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width * 0.70,
      child: Column(
        children: <Widget>[
          GenericDialogTitle(
              title: Localization.of(context).markerSettingsTitle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              BusMarkerTile(
                markersToShow: markersToShow,
              ),
              BikeMarkerTile(
                markersToShow: markersToShow,
              ),
              BothMarkersTile(
                markersToShow: markersToShow,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class BikeMarkerTile extends StatelessWidget {
  const BikeMarkerTile({Key key, @required this.markersToShow})
      : super(key: key);
  final MarkersToShow markersToShow;

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      onTap: () {
        _settingsBloc.changeSetting(markersToShow: MarkersToShow.BIKE);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).accentColor,
                style: markersToShow == MarkersToShow.BIKE
                    ? BorderStyle.solid
                    : BorderStyle.none),
            borderRadius: const BorderRadius.all(Radius.circular(20.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const BikeIcon(
              height: 25,
            ),
            Text(
              Localization.of(context).markerOptionBike,
            ),
          ],
        ),
      ),
    );
  }
}

class BusMarkerTile extends StatelessWidget {
  const BusMarkerTile({Key key, @required this.markersToShow})
      : super(key: key);

  final MarkersToShow markersToShow;

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      onTap: () {
        _settingsBloc.changeSetting(markersToShow: MarkersToShow.BUS);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).accentColor,
                style: markersToShow == MarkersToShow.BUS
                    ? BorderStyle.solid
                    : BorderStyle.none),
            borderRadius: const BorderRadius.all(Radius.circular(20.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const BusIcon(
              height: 25,
            ),
            Text(
              Localization.of(context).markerOptionBus,
            ),
          ],
        ),
      ),
    );
  }
}

class BothMarkersTile extends StatelessWidget {
  const BothMarkersTile({Key key, @required this.markersToShow})
      : super(key: key);
  final MarkersToShow markersToShow;

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      onTap: () {
        _settingsBloc.changeSetting(markersToShow: MarkersToShow.BOTH);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).accentColor,
                style: markersToShow == MarkersToShow.BOTH
                    ? BorderStyle.solid
                    : BorderStyle.none),
            borderRadius: const BorderRadius.all(Radius.circular(20.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const BusIcon(
                  height: 25,
                ),
                Text(
                  ' + ',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                const BikeIcon(
                  height: 25,
                ),
              ],
            ),
            Text(
              Localization.of(context).markerOptionBoth,
            ),
          ],
        ),
      ),
    );
  }
}
