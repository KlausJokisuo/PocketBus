import 'dart:async';
import 'dart:convert';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/Models/Foli/schedules_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/Models/notification_model.dart';
import 'package:pocket_bus/Notification/notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationBloc implements BlocBase {
  NotificationBloc() {
    _notifications.setupNotification();
//    _notifications.busNotification(
//        notificationModel: NotificationModel(
//      stopData: StopData(customName: 'Test Custom Name', busStopCode: '123'),
//      schedule: Schedule(
//        lineref: '7A',
//        tripref: '999',
//      ),
//      selectedMinutes: 12,
//      notificationTime: DateTime.now().add(Duration(seconds: 1)),
//    ));
  }

  final Notifications _notifications = Notifications();
  List<NotificationModel> _pendingNotificationList = [];

  final BehaviorSubject<List<NotificationModel>> _notificationsController =
      BehaviorSubject<List<NotificationModel>>();

  Sink<List<NotificationModel>> get _inNotifications =>
      _notificationsController.sink;

  Stream<List<NotificationModel>> get outNotifications =>
      _notificationsController.stream;

  @override
  void dispose() {
    _notificationsController?.close();
  }

  Future<void> loadNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _notifications.flutterLocalNotificationsPlugin
            .pendingNotificationRequests();

//    ${notificationModel.notificationTime.toString()}|
//    ${notificationModel.selectedMinutes}|
//    ${notificationModel.scheduleJson}|
//    ${notificationModel.stopDataJson}

    _pendingNotificationList = pendingNotifications.map((pendingNotification) {
      final List<String> decodedPayload =
          pendingNotification.payload.split('|--|');
//      if (decodedPayload.isEmpty)
//        return NotificationModel(
//          stopData: StopData(customName: 'Test Custom Name'),
//          schedule: Schedule(lineref: '7A', tripref: '999'),
//        );
      return NotificationModel(
        notificationTime: DateTime.parse(decodedPayload[0]),
        selectedMinutes: int.parse(decodedPayload[1]),
        schedule: Schedule.fromJson(json.decode(decodedPayload[2])),
        stopData: BusStop.fromJson(json.decode(decodedPayload[3])),
      );
    }).toList(growable: false);

    _inNotifications.add(_pendingNotificationList);
  }

  void addNotification(NotificationModel notificationModel) {
    _notifications.flutterLocalNotificationsPlugin
        .cancel(notificationModel.notificationId);
    _notifications.busNotification(
        notificationModel: NotificationModel(
      schedule: notificationModel.schedule,
      selectedMinutes: notificationModel.selectedMinutes,
      notificationTime: notificationModel.notificationTime,
      stopData: notificationModel.stopData,
    ));
    loadNotifications();
  }

  void removeNotification(NotificationModel notificationModel) {
    _notifications.flutterLocalNotificationsPlugin
        .cancel(notificationModel.notificationId);
    loadNotifications();
  }

  bool isAlarm(NotificationModel notificationModel) {
    return _pendingNotificationList
        .any((_notification) => _notification == notificationModel);
  }
}
