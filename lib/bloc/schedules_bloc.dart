import 'dart:async';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/Models/Foli/schedules_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:rxdart/rxdart.dart';

class SchedulesBloc implements BlocBase {
  Timer _scheduleTimer;
  Timer _trackedScheduleTimer;

  //Just a check if the trackMap is active then we will not refresh mainMapScreen schedules
  bool _trackMapActive = false;

  final PublishSubject<ScheduleData> _schedulesController =
      PublishSubject<ScheduleData>();
  Sink<ScheduleData> get _inSchedules => _schedulesController.sink;
  Stream<ScheduleData> get outSchedules => _schedulesController.stream;

  final PublishSubject<ScheduleData> _trackedSchedulesController =
      PublishSubject<ScheduleData>();
  Sink<ScheduleData> get _inTrackedSchedules =>
      _trackedSchedulesController.sink;
  Stream<ScheduleData> get outTrackedSchedules =>
      _trackedSchedulesController.stream;

  final BehaviorSubject<bool> _schedulesLoadingController =
      BehaviorSubject<bool>();
  Sink<bool> get _inLoading => _schedulesLoadingController.sink;
  Stream<bool> get outLoading => _schedulesLoadingController.stream;

  @override
  void dispose() {
    _schedulesController?.close();
    _trackedSchedulesController?.close();
    _schedulesLoadingController?.close();
  }

  //Gets schedule data on mainScheduleScreen
  Future<void> _getSchedule(BusStop currentStop) async {
    //Check if trackMapIsActive if it's not then it's OK to refresh mainScreenSchedules
    if (!_trackMapActive) {
      _inLoading.add(true);

      final ScheduleData scheduleData =
          await fetchScheduleData(currentStop.busStopCode.toString());
      scheduleData.schedules.sort((scheduleA, scheduleB) => scheduleA
          .expectedarrivaltime
          .compareTo(scheduleB.expectedarrivaltime));

      _inSchedules.add(scheduleData);
      _inLoading.add(false);
    }
  }

  Future<void> refreshSchedules(BusStop currentStop) async {
    //Make sure that we have only 1 Timer running at once.
    _scheduleTimer?.cancel();
    await _getSchedule(currentStop);
    _scheduleTimer = Timer.periodic(
        const Duration(seconds: StaticValues.scheduleRefreshInterval), (timer) {
      _getSchedule(currentStop);
    });
  }

  //Gets schedule data on trackedScheduleScreen
  Future<void> _getTrackedSchedule(BusStop currentStop, String tripRef) async {
    _inLoading.add(true);

    final ScheduleData scheduleData =
        await fetchScheduleData(currentStop.busStopCode.toString());
    scheduleData.schedules.sort((scheduleA, scheduleB) =>
        scheduleA.expectedarrivaltime.compareTo(scheduleB.expectedarrivaltime));

    //If we find  tracked schedule we will move it to top of the schedule list
    final Schedule tempSchedule = scheduleData.schedules.firstWhere(
        (schedule) => schedule.tripref == tripRef,
        orElse: () => null);
    if (tempSchedule != null) {
      scheduleData.schedules.remove(tempSchedule);
      scheduleData.schedules.insert(0, tempSchedule);
    }

    _inTrackedSchedules.add(scheduleData);
    _inLoading.add(false);
  }

  Future<void> refreshTrackedSchedules(
      BusStop currentStop, String tripRef) async {
    //Make sure that we have only 1 Timer running at once.
    _trackedScheduleTimer?.cancel();
    await _getTrackedSchedule(currentStop, tripRef);
    _trackedScheduleTimer = Timer.periodic(
        const Duration(seconds: StaticValues.scheduleRefreshInterval), (timer) {
      _getTrackedSchedule(currentStop, tripRef);
    });
  }

  void cancelScheduleTimer() => _scheduleTimer?.cancel();

  void cancelTrackedScheduleTimer() => _trackedScheduleTimer?.cancel();

  bool get trackMapActive => _trackMapActive;

  set trackMapActive(bool value) => _trackMapActive = value;
}
