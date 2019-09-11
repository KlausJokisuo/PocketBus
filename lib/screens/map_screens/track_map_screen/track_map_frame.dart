import 'package:pocket_bus/Misc/custom_tooltip.dart';
import 'package:pocket_bus/Models/Foli/schedules_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';
import 'package:pocket_bus/screens/map_screens/track_map_screen/track_map_body.dart';

class TrackMapFrame extends StatelessWidget {
  const TrackMapFrame(
      {Key key, @required this.currentStop, @required this.schedule})
      : super(key: key);
  final Schedule schedule;
  final BusStop currentStop;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          TrackMapBody(
            currentStop: currentStop,
            vehicleRef: schedule.vehicleref,
            tripRef: schedule.tripref,
          ),
          const FloatingBackButton(),
          const FloatingInfoButton(),
        ],
      ),
    );
  }
}

class FloatingBackButton extends StatelessWidget {
  const FloatingBackButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.95, 0.80),
      child: FloatingActionButton(
        heroTag: 'backButton',
        mini: true,
        child: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class FloatingInfoButton extends StatelessWidget {
  const FloatingInfoButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.95, -0.8),
      child: CustomTooltip(
        message: Localization.of(context).miscBusLocationUpdated,
        child: const Icon(
          Icons.info_outline,
          size: 32.0,
        ),
      ),
    );
  }
}
