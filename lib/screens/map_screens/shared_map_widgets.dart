import 'dart:async';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationButton extends StatefulWidget {
  const LocationButton(
      {Key key,
      this.zoomLevel = 17.0,
      @required this.mapController,
      @required this.cameraPositionNotifier})
      : super(key: key);

  final double zoomLevel;
  final ValueNotifier<CameraPosition> cameraPositionNotifier;
  final Completer<GoogleMapController> mapController;

  @override
  _LocationButtonState createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  double _bearing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));

    _scaleAnimation = Tween(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            }
          });

    //We need to call addListener so the bearing can be updated AFTER the widget has been created
    widget.cameraPositionNotifier.addListener(
        () => _bearing = widget.cameraPositionNotifier.value.bearing);
  }

  @override
  void dispose() {
    _controller?.dispose();
    widget.cameraPositionNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.95, 0.80),
      child: AnimatedBuilder(
          animation: _scaleAnimation,
          child: FloatingActionButton(
            heroTag: 'myLocationButton',
            onPressed: () async {
              _controller.forward();
              final GoogleMapController controller =
                  await widget.mapController.future;
              final Geolocator _geoLocator = Geolocator();
              final GeolocationStatus _geoLocationStatus =
                  await _geoLocator.checkGeolocationPermissionStatus();
              if (_geoLocationStatus == GeolocationStatus.granted) {
                await _geoLocator
                    .getLastKnownPosition(
                        desiredAccuracy: LocationAccuracy.high)
                    .then((position) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        bearing: _bearing ?? 0.0,
                        zoom: 17.0,
                      ),
                    ),
                  );
                });
              } else {
                await locationPermissionsDialog(context);
              }
            },
            child: const Icon(Icons.my_location),
          ),
          builder: (BuildContext context, Widget child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          }),
    );
  }
}

class MapTypeSwitcher extends StatefulWidget {
  const MapTypeSwitcher({Key key, @required this.currentMapType})
      : super(key: key);
  final MapType currentMapType;

  @override
  _MapTypeSwitcherState createState() => _MapTypeSwitcherState();
}

class _MapTypeSwitcherState extends State<MapTypeSwitcher>
    with TickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _scaleAnimation;
  Tween<double> _rotationTween;
  Animation<double> _rotationAnimation;

  SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc ??= BlocProvider.of<SettingsBloc>(context);

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    _rotationTween = Tween(begin: 0.0);
    _rotationAnimation = _rotationTween
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween(begin: 1.0, end: 1.4)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            }
          });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.95, -0.7),
      child: AnimatedBuilder(
          animation: _scaleAnimation,
          child: FloatingActionButton(
            mini: true,
            heroTag: 'mapSwitcherButton',
            child: const Icon(Icons.layers),
            onPressed: () {
              _controller.forward();
              _rotationTween.end =
                  widget.currentMapType == MapType.satellite ? 2.0 : -2.0;
              final MapType nextType =
                  MapType.values[widget.currentMapType.index == 2 ? 1 : 2];
              _settingsBloc.changeSetting(mapType: nextType);
            },
          ),
          builder: (context, Widget child) {
            return Transform(
              transform: Matrix4.diagonal3Values(
                  _scaleAnimation.value, _scaleAnimation.value, 1.0)
                ..rotateZ(_rotationAnimation.value),
              alignment: Alignment.center,
              child: child,
            );
          }),
    );
  }
}

//TODO: When Föli implements proper RSS feed to traffic news

//class RSSFeedButton extends StatefulWidget {
//  const RSSFeedButton({Key key}) : super(key: key);
//  @override
//  _RSSFeedButtonState createState() => _RSSFeedButtonState();
//}
//
//class _RSSFeedButtonState extends State<RSSFeedButton>
//    with SingleTickerProviderStateMixin {
//  AnimationController _controller;
//
//  @override
//  void initState() {
//    _controller = AnimationController(vsync: this);
//    super.initState();
//  }
//
//  @override
//  void dispose() {
//    _controller?.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Align(
//      alignment: const Alignment(-0.95, -0.7),
//      child: FloatingActionButton(
//        heroTag: 'rssFeedButton',
//        mini: true,
//        child: const Icon(Icons.rss_feed),
//        onPressed: () {
//          showCustomDialog(context, RssFeedScreen());
//        },
//      ),
//    );
//  }
//}
