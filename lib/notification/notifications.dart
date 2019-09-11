import 'dart:async';

import 'package:pocket_bus/Models/notification_model.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/Theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationID { bus }

class Notifications {
  Notifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  final String channelId = '${StaticValues.appName}id';
  final String channelName = StaticValues.appName;
  final String channelDescription = '${StaticValues.appName} description';
  final Color notificationColor = darkTheme.accentColor;
  final Color notificationLedColor = darkTheme.accentColor;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void setupNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/notification_icon',
    );
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> scheduleNotification(
      {String title,
      body,
      DateTime notificationDateTime,
      payLoad,
      int id}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelId, channelName, channelDescription,
            importance: Importance.Max,
            priority: Priority.High,
            color: notificationColor,
            ledColor: notificationLedColor,
            enableVibration: true,
            enableLights: true,
            ledOnMs: 1000,
            ledOffMs: 500,
            channelShowBadge: true);
    final IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      notificationDateTime,
      platformChannelSpecifics,
      payload: payLoad,
    );
  }

  Future<void> busNotification(
      {@required NotificationModel notificationModel}) async {
    //We use |--| as Separator for the PayLoad
    final String payload =
        '${notificationModel.notificationTime.toString()}|--|${notificationModel.selectedMinutes}|--|${notificationModel.scheduleJson}|--|${notificationModel.stopJson}';

    await scheduleNotification(
        notificationDateTime: notificationModel.notificationTime,
        title: 'Incoming Bus - ${notificationModel.schedule.lineref}',
        body:
            'Stop No. ${notificationModel.stopData.busStopCode} ${notificationModel.stopData.customName ?? notificationModel.stopData.stopName} in ${notificationModel.selectedMinutes} min',
        payLoad: payload,
        id: notificationModel.notificationId);
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {}
  }
}
