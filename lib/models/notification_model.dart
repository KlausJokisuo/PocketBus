import 'dart:convert';

import 'package:pocket_bus/Models/Foli/schedules_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:meta/meta.dart';

class NotificationModel {
  NotificationModel(
      {this.notificationTime,
      @required this.schedule,
      @required this.stopData,
      this.selectedMinutes}) {
    scheduleJson = json.encode(schedule.toJson());
    stopJson = json.encode(stopData.toJson());
    notificationId = int.parse(schedule.tripref.replaceAll(RegExp('\\D+'), ''));
  }

  final int selectedMinutes;
  final DateTime notificationTime;
  final Schedule schedule;
  final BusStop stopData;
  String scheduleJson;
  String stopJson;
  int notificationId;

  @override
  String toString() {
    return 'NotificationModel{selectedMinutes: $selectedMinutes, notificationTime: $notificationTime, schedule: $schedule, stopData: $stopData, notificationId: $notificationId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          notificationId == other.notificationId;

  @override
  int get hashCode => notificationId.hashCode;
}
