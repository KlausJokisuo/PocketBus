import 'dart:async';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/Models/Foli/vehicle_data.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class BusTrackingBloc implements BlocBase {
  Timer _busTrackingLocationTimer;

  final PublishSubject<Vehicle> _busTrackingController =
      PublishSubject<Vehicle>();
  Sink<Vehicle> get _inTracking => _busTrackingController.sink;
  Stream<Vehicle> get outTracking => _busTrackingController.stream;

  @override
  void dispose() {
    _busTrackingController?.close();
  }

  Future<void> _getVehicle(String vehicleRef) async {
    debugPrint('_getVehicle');
    final VechilesData vehiclesData = await fetchVehiclesData();
    final Vehicle vehicle = vehiclesData.result.vehicles[vehicleRef];

    _inTracking.add(vehicle);
  }

  Future<void> refreshVehicleLocation(
      BusStop currentStop, String vehicleRef) async {
    //Make sure that we have only 1 Timer running at once.
    _busTrackingLocationTimer?.cancel();
    await _getVehicle(vehicleRef);
    _busTrackingLocationTimer = Timer.periodic(
        const Duration(seconds: StaticValues.busLocationRefreshInterval),
        (timer) {
      _getVehicle(vehicleRef);
    });
  }

  void cancelBusTrackingTimer() => _busTrackingLocationTimer?.cancel();
}
