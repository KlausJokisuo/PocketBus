import 'dart:async';
import 'dart:typed_data';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/bus_tracking_bloc.dart';
import 'package:pocket_bus/BloC/schedules_bloc.dart';

import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/BloC/stops_bloc.dart';

import 'package:pocket_bus/Misc/custom_sheet.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/Foli/shapes_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/Models/Foli/trips_data.dart';
import 'package:pocket_bus/Models/Foli/vehicle_data.dart';
import 'package:pocket_bus/screens/map_screens/shared_map_widgets.dart';
import 'package:pocket_bus/Screens/Sheets/tracked_schedule_screen.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class TrackMapBody extends StatefulWidget {
  const TrackMapBody(
      {Key key,
      @required this.currentStop,
      @required this.vehicleRef,
      @required this.tripRef})
      : super(key: key);
  final String vehicleRef;
  final String tripRef;
  final BusStop currentStop;

  @override
  TrackMapBodyState createState() {
    return TrackMapBodyState();
  }
}

class TrackMapBodyState extends State<TrackMapBody> {
  //Small hack to store current came position. TODO: Fix this when it's possible to retrieve camera data via GoogleMap controller.
  final ValueNotifier<CameraPosition> _cameraPositionNotifier =
      ValueNotifier<CameraPosition>(const CameraPosition(target: LatLng(0, 0)));

  final Completer<GoogleMapController> _trackMapController = Completer();
  final BitmapDescriptor selectedStop =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  final BitmapDescriptor startStop =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  final BitmapDescriptor finalStop =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
  final BitmapDescriptor normalStop = BitmapDescriptor.defaultMarker;
  BitmapDescriptor customBusMarkerIcon;

  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Map<MarkerId, Marker> _busTrackingMarker = <MarkerId, Marker>{};
  final Map<PolylineId, Polyline> _busRouteLines = <PolylineId, Polyline>{};

  BusTrackingBloc _busTrackingBloc;
  SettingsBloc _settingsBloc;
  StopsBloc _stopsBloc;
  SchedulesBloc _schedulesBloc;

  Future<void> _onMarkerTapped(MarkerId markerId,
      {@required BusStop stopData}) async {
    final GoogleMapController controller = await _trackMapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _markers[markerId].position,
          bearing: _cameraPositionNotifier.value.bearing,
          zoom: 16.0,
        ),
      ),
    );

    await showModalBottomSheetCustom(
        context: context,
        builder: (BuildContext context) => TrackedScheduleScreen(
              currentStop: stopData,
              trackedTripReference: widget.tripRef,
            ));
  }

  Future<void> _generateStopMarkersAndRouteLines(List<BusStop> busStops) async {
    //Only create markers on first run
    if (_markers.isNotEmpty) {
      return;
    }

    debugPrint('_generateStopMarkersAndRouteLines');

    final List<TripsData> tripsData = await fetchTripsData(widget.tripRef);
    final List<ShapesData> shapesData =
        await fetchShapesData(tripsData[0].shapeId);

    //Assign Stop markers to set initially to handle duplicates
    final Set<BusStop> setStopMarkersToDraw = <BusStop>{};
    final Set<LatLng> polylinesToDraw = <LatLng>{};

    for (final shape in shapesData) {
      final LatLng latLng = LatLng(shape.lat, shape.lon);
      polylinesToDraw.add(latLng);
      for (final stop in busStops) {
        if (stop.stopLgn == latLng) {
          setStopMarkersToDraw.add(stop);
        }
      }
    }

    final List<BusStop> _listStopMarkersToDraw = setStopMarkersToDraw.toList();

    for (int stopMarkerIndex = 0;
        stopMarkerIndex < _listStopMarkersToDraw.length;
        stopMarkerIndex++) {
      final BusStop stop = _listStopMarkersToDraw[stopMarkerIndex];

      final MarkerId busStopMarkerId = MarkerId((stopMarkerIndex).toString());
      final Marker busStopMarker = Marker(
          markerId: busStopMarkerId,
          zIndex: 0.0,
          consumeTapEvents: true,
          visible: true,
          position: stop.stopLgn,
          icon: _chooseMarkerColor(
              stopMarkerIndex, _listStopMarkersToDraw.length - 1, stop.stopLgn),
          onTap: () => _onMarkerTapped(busStopMarkerId, stopData: stop));
      _markers[busStopMarker.markerId] = busStopMarker;
    }

    const String polylineIdVal = 'polyline_route';
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline busRouteLine = Polyline(
      polylineId: polylineId,
      color: Theme.of(context).accentColor,
      width: 2,
      points: polylinesToDraw.toList(),
    );

    _busRouteLines[polylineId] = busRouteLine;
  }

  Future<void> _generateBusTrackingMarkers(Vehicle trackedVehicle) async {
    //Skip expensive _getAssetIcon method if the customMarkerIcon is not null
    customBusMarkerIcon ??= await _getAssetIcon(
        context, 'images/icons8-bus-48.png', trackedVehicle.lineref);

    _markers.removeWhere(
        (markerId, marker) => markerId.value.contains('busTrackMarker'));
    _busTrackingMarker.clear();

    final MarkerId busTrackingMarkerId =
        MarkerId('busTrackMarker_${trackedVehicle.lineref}'.toString());

    final Marker busTrackingMarker = Marker(
      zIndex: 1.0,
      markerId: busTrackingMarkerId,
      consumeTapEvents: true,
      visible: true,
      icon: customBusMarkerIcon,
      position: LatLng(trackedVehicle.latitude, trackedVehicle.longitude),
    );
    _busTrackingMarker[busTrackingMarker.markerId] = busTrackingMarker;

    _markers.addAll(_busTrackingMarker);
  }

  Future<BitmapDescriptor> _getAssetIcon(
      BuildContext context, String assetImagePath, String busName) async {
    final ByteData byteData =
        await customBusMarkerData(assetImagePath, busName);
    final BitmapDescriptor bitmap =
        BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    return bitmap;
  }

  BitmapDescriptor _chooseMarkerColor(
      int markerIndex, stopMarkersToDrawSize, LatLng stopLatLng) {
    if (stopLatLng == widget.currentStop.stopLgn) {
      return selectedStop;
    }
    if (markerIndex == 0) {
      return startStop;
    }
    if (markerIndex == stopMarkersToDrawSize) {
      return finalStop;
    }

    return normalStop;
  }

  void _onMapCreated(GoogleMapController controller) {
    _trackMapController.complete(controller);
    debugPrint('_onMapCreated');
  }

  @override
  void initState() {
    super.initState();
    _stopsBloc ??= BlocProvider.of<StopsBloc>(context);
    _busTrackingBloc ??= BlocProvider.of<BusTrackingBloc>(context);
    _settingsBloc ??= BlocProvider.of<SettingsBloc>(context);
    _schedulesBloc ??= BlocProvider.of<SchedulesBloc>(context);
    _schedulesBloc.trackMapActive = true;
    _busTrackingBloc.refreshVehicleLocation(
        widget.currentStop, widget.vehicleRef);
  }

  @override
  void dispose() {
    _busTrackingBloc.cancelBusTrackingTimer();
    _schedulesBloc.trackMapActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building TrackMapBody');

    return Stack(
      children: <Widget>[
        StreamBuilder<List<dynamic>>(
            stream: CombineLatestStream(
              [
                _settingsBloc.outSettings,
                _busTrackingBloc.outTracking,
                _stopsBloc.outStops
              ],
              (data) => data,
            ),
            builder: (context, streamSnapshot) {
              if (!streamSnapshot.hasData) {
                return const CenterSpinner();
              }

              return FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    _generateBusTrackingMarkers(streamSnapshot.data[1]),
                    _generateStopMarkersAndRouteLines(streamSnapshot.data[2]),
                  ]),
                  builder: (context, _) {
                    if (_busRouteLines.isEmpty) {
                      return const CenterSpinner();
                    }

                    return GoogleMap(
                      indoorViewEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: streamSnapshot.data[0].mapType,
                      markers: Set<Marker>.of(_markers.values),
                      polylines: Set<Polyline>.of(_busRouteLines.values),
                      initialCameraPosition: CameraPosition(
                        target: widget.currentStop.stopLgn,
                        zoom: 13.5,
                      ),
                      tiltGesturesEnabled: false,
                      compassEnabled: false,
                      minMaxZoomPreference:
                          const MinMaxZoomPreference(11.0, 17.5),
                      onCameraMove: (cameraPosition) =>
                          _cameraPositionNotifier.value = cameraPosition,
                      onMapCreated: _onMapCreated,
                    );
                  });
            }),
        LocationButton(
          mapController: _trackMapController,
          zoomLevel: 15.5,
          cameraPositionNotifier: _cameraPositionNotifier,
        ),
      ],
    );
  }
}

// Might implement in future for "smoother" BusMarker movement
//    Future.forEach(
//        equidisLatLngBetweenLatLngs(
//            LatLng(60.451570, 22.266984), LatLng(60.450252, 22.266619), 65),
//            (f) async {
//          await Future.delayed(const Duration(milliseconds: 16), () {
//            debugPrint("moveMarker");
//            final Marker marker = Marker(
//                markerId: MarkerId('1'),
//                consumeTapEvents: true,
//                visible: true,
//                position: f,
//                icon: BitmapDescriptor.defaultMarkerWithHue(
//                    BitmapDescriptor.hueGreen));
//
//            _allMarkers[MarkerId('1')] = marker;
//            _settingsBloc.notify();
//          });
//        });
