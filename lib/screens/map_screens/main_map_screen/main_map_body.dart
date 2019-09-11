import 'dart:async';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/follari_bloc.dart';
import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/BloC/stops_bloc.dart';
import 'package:pocket_bus/Models/Foli/follari_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/Models/settingsData.dart';
import 'package:pocket_bus/screens/map_screens/shared_map_widgets.dart';
import 'package:pocket_bus/Screens/Sheets/main_schedule_screen.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/misc/custom_sheet.dart';
import 'package:pocket_bus/Screens/Sheets/follari_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

final Completer<GoogleMapController> mainMapController = Completer();

class MainMapBody extends StatelessWidget {
  MainMapBody({Key key}) : super(key: key);
  //Small hack to store current camera position.
  // TODO: Fix this when it's possible to retrieve camera data via GoogleMap controller.
  final ValueNotifier<CameraPosition> _cameraPositionNotifier =
      ValueNotifier<CameraPosition>(const CameraPosition(target: LatLng(0, 0)));

  final LatLng _turkuCentral =
      LatLng(StaticValues.turkuLtng.latitude, StaticValues.turkuLtng.longitude);

  final List<Map<MarkerId, Marker>> _markersList = <Map<MarkerId, Marker>>[
    {},
    {},
    {}
  ];

  LatLng _determineStartingLocation(Settings settings, LatLng currentLocation) {
    switch (settings.locationToUse) {
      case LocationToUse.CURRENT:
        return currentLocation ?? StaticValues.turkuLtng;
        break;
      case LocationToUse.TURKU:
        return LatLng(
            StaticValues.turkuLtng.latitude, StaticValues.turkuLtng.longitude);
        break;
      default:
        return _turkuCentral;
    }
  }

  Stream<LatLng> _getCurrentLocation() async* {
    LatLng _location;
    try {
      final Position _position = await Geolocator().getLastKnownPosition();
      _location = LatLng(_position.latitude, _position.longitude);
    } catch (e) {
      _location = _turkuCentral;
      print(e);
    }
    yield _location;
    //If _currentLocation is null use StaticValues.turkuLtng value (Null usually happens when user has denied Location permissions)
  }

  void _onMapCreated(GoogleMapController controller) {
    mainMapController.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final FollariBloc _follariBloc = BlocProvider.of<FollariBloc>(context);
    final StopsBloc _stopsBloc = BlocProvider.of<StopsBloc>(context);

    void busStopMarkerCallback(MarkerId markerId, BusStop stopData) {
      debugPrint('busStopMarkerCallback');

      showModalBottomSheetCustom(
          context: context,
          builder: (BuildContext context) => MainScheduleScreen(
                currentStop: stopData,
                showTopBar: true,
              ));
    }

    void follariStopMarkerCallback(MarkerId markerId, Rack rack) {
      debugPrint('follariStopMarkerCallback');
      showModalBottomSheetCustom(
          context: context,
          builder: (BuildContext context) => FollariScreen(
                rackIdentifier: rack,
              ));
    }

    Future<void> _onMarkerTapped(MarkerId markerId, MarkersToShow markersToShow,
        {BusStop stopData, Rack rack}) async {
      debugPrint('_onMarkerTapped');

      final GoogleMapController controller = await mainMapController.future;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _markersList[markersToShow.index][markerId].position,
            bearing: _cameraPositionNotifier.value.bearing,
            zoom: 17.0,
          ),
        ),
      );

      stopData == null
          ? follariStopMarkerCallback(markerId, rack)
          : busStopMarkerCallback(markerId, stopData);
    }

    void _generateBusAndFollariMarkers(
        List<BusStop> _busStops, List<Rack> _rackStops) {
      final Map<MarkerId, Marker> _busStopMarkers = <MarkerId, Marker>{};
      final Map<MarkerId, Marker> _follariStopMarkers = <MarkerId, Marker>{};

      debugPrint('_generateBusAndFollariMarkers');
      int markerIndex = 0;

      for (final stop in _busStops) {
        final MarkerId busStopMarkerId = MarkerId((markerIndex++).toString());
        final Marker busStopMarker = Marker(
            markerId: busStopMarkerId,
            consumeTapEvents: true,
            visible: true,
            position: stop.stopLgn,
            onTap: () => _onMarkerTapped(busStopMarkerId, MarkersToShow.BUS,
                stopData: stop));

        _busStopMarkers[busStopMarker.markerId] = busStopMarker;
      }

      for (final rack in _rackStops) {
        final MarkerId follariMarkerId = MarkerId((markerIndex++).toString());
        final Marker follariStopMarker = Marker(
            markerId: follariMarkerId,
            consumeTapEvents: true,
            visible: true,
            position: rack.rackLng,
            onTap: () => _onMarkerTapped(follariMarkerId, MarkersToShow.BIKE,
                rack: rack),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen));

        _follariStopMarkers[follariStopMarker.markerId] = follariStopMarker;
      }

      _markersList[MarkersToShow.BUS.index] = _busStopMarkers;
      _markersList[MarkersToShow.BIKE.index] = _follariStopMarkers;

      _markersList[MarkersToShow.BOTH.index] = {
        ..._busStopMarkers,
        ..._follariStopMarkers
      };
    }

    debugPrint('Building MapBody');
    return StreamBuilder<List<dynamic>>(
        stream: CombineLatestStream(
          [
            _settingsBloc.outSettings.distinct((previousValue, nextValue) =>
                previousValue.markersToShow == nextValue.markersToShow &&
                previousValue.mapType == nextValue.mapType),
            _getCurrentLocation(),
            _stopsBloc.outStops,
            _follariBloc.outRacks
          ],
          (data) => data,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenterSpinner();
          }

          final CameraPosition _kInitialPosition = CameraPosition(
            target:
                _determineStartingLocation(snapshot.data[0], snapshot.data[1]),
            zoom: 17.0,
          );

          if (_markersList[MarkersToShow.BOTH.index].isEmpty) {
            _generateBusAndFollariMarkers(snapshot.data[2], snapshot.data[3]);
          }

          return Stack(children: <Widget>[
            GoogleMap(
              indoorViewEnabled: false,
              myLocationEnabled: true,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              mapType: snapshot.data[0].mapType,
              markers: Set<Marker>.of(
                  _markersList[snapshot.data[0].markersToShow.index].values),
              initialCameraPosition: _kInitialPosition,
              tiltGesturesEnabled: false,
              compassEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(14.0, 17.5),
              onCameraMove: (cameraPosition) =>
                  _cameraPositionNotifier.value = cameraPosition,
              onMapCreated: _onMapCreated,
            ),
            MapTypeSwitcher(
              currentMapType: snapshot.data[0].mapType,
            ),
            LocationButton(
              mapController: mainMapController,
              cameraPositionNotifier: _cameraPositionNotifier,
            ),
          ]);
        });
  }
}
