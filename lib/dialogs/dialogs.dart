import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:pocket_bus/Misc/custom_tooltip.dart';
import 'package:pocket_bus/Misc/touch_stepper.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DialogAction { APPLY, DISCARD, RESET, REMOVE }

final _formKey = GlobalKey<FormState>();

bool _submit() {
  final form = _formKey.currentState;

  if (form.validate()) {
    form.save();
    return true;
  }
  return false;
}

Future<DialogAction> favoriteEditDialog(
    BuildContext context, TextEditingController controller) async {
  final action = await showCustomDialog(
      context,
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                Localization.of(context).favoriteEditTitle,
              ),
            ),
            InkWell(
              onTap: () {
                return Navigator.of(context).pop(DialogAction.RESET);
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Icon(
                  Icons.refresh,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: InkWell(
                onTap: () {
                  return Navigator.of(context).pop(DialogAction.REMOVE);
                },
                child: const Icon(
                  Icons.delete,
                ),
              ),
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
              topLeft: Radius.circular(4.0),
              topRight: Radius.circular(4.0)),
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            validator: (val) => val.isEmpty
                ? Localization.of(context).favoriteEditFromWarning
                : null,
            onEditingComplete: () {
              if (_submit()) {
                return Navigator.of(context).pop(DialogAction.APPLY);
              }
              return false;
            },
            controller: controller,
            autofocus: true,
            cursorColor: Theme.of(context).accentColor,
            decoration: InputDecoration(
                labelStyle: TextStyle(color: Theme.of(context).accentColor),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                labelText: Localization.of(context).favoriteEditFormTitle,
                hintText: Localization.of(context).favoriteEditFormHint),
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            color: Theme.of(context).accentColor,
            onPressed: () {
              if (_submit()) {
                return Navigator.of(context).pop(DialogAction.APPLY);
              }
              return false;
            },
            child: Text(
              Localization.of(context).miscApply,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(DialogAction.DISCARD),
            child: Text(
              Localization.of(context).miscDiscard,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
            ),
          ),
        ],
      ),
      createMaterial: false);

  return action ?? DialogAction.DISCARD;
}

Future<DialogAction> noConnectionDialog(BuildContext context) async {
  final action = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Oops!'),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0)),
          ),
          content: Text(Localization.of(context).connectionDialogWarning),
          actions: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              color: Theme.of(context).accentColor,
              onPressed: () {
                return Navigator.of(context).pop(DialogAction.RESET);
              },
              child: Text(
                Localization.of(context).miscRefresh,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            FlatButton(
              onPressed: () {
                return SystemChannels.platform
                    .invokeMethod('SystemNavigator.pop');
              },
              child: Text(
                Localization.of(context).miscQuit,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
  return action ?? DialogAction.DISCARD;
}

Future<DialogAction> locationPermissionsDialog(BuildContext context) async {
  final action = await showCustomDialog(
      context,
      AlertDialog(
        title: Row(
          children: <Widget>[
            Expanded(
                child: Text(Localization.of(context).locationDialogWarning)),
            const BouncyWidget(
              child: Icon(
                Icons.location_off,
                size: 50,
              ),
              duration: Duration(milliseconds: 500),
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
              topLeft: Radius.circular(4.0),
              topRight: Radius.circular(4.0)),
        ),
        actions: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            color: Theme.of(context).accentColor,
            onPressed: AppSettings.openAppSettings,
            child: Text(
              Localization.of(context).locationDialogWarningButton,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(DialogAction.DISCARD),
            child: Text(
              Localization.of(context).miscCancel,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
            ),
          ),
        ],
      ),
      createMaterial: false);

  return action ?? DialogAction.DISCARD;
}

Future<DialogAction> locationPermissionDialog(BuildContext context) async {
  final action = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Row(
            children: <Widget>[
              Expanded(
                  child: Text(Localization.of(context).locationDialogWarning)),
              const Icon(
                Icons.not_listed_location,
                size: 50,
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0)),
          ),
          actions: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              color: Theme.of(context).accentColor,
              onPressed: AppSettings.openAppSettings,
              child: Text(
                Localization.of(context).locationDialogWarningButton,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(DialogAction.DISCARD),
              child: Text(
                Localization.of(context).miscCancel,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
  return action ?? DialogAction.DISCARD;
}

Future<List<dynamic>> alarmDialog(
    BuildContext context, int busArrivalTimeMinutes) async {
  int notificationMinutes = 5;
  final int stepperMaxValue = busArrivalTimeMinutes - 5;
  final action = await showCustomDialog(
      context,
      AlertDialog(
        title: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                Localization.of(context).miscAlarm,
              ),
            ),
            CustomTooltip(
              message: Localization.of(context).miscBusNotificationInfo,
              child: Icon(
                Icons.info_outline,
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
              topLeft: Radius.circular(4.0),
              topRight: Radius.circular(4.0)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            StepperTouch(
              initialValue: 5,
              minusValue: 5,
              plusValue: 5,
              minValue: 5,
              maxValue: min(stepperMaxValue, 60),
              withSpring: true,
              onChanged: (int value) => notificationMinutes = value,
            ),
          ],
        ),
        actions: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            color: Theme.of(context).accentColor,
            onPressed: () {
              return Navigator.of(context)
                  .pop([DialogAction.APPLY, notificationMinutes]);
            },
            child: Text(
              Localization.of(context).miscApply,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          FlatButton(
            onPressed: () {
              return Navigator.of(context)
                  .pop([DialogAction.DISCARD, notificationMinutes]);
            },
            child: Text(
              Localization.of(context).miscDiscard,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
            ),
          ),
        ],
      ),
      createMaterial: false);

  return action ?? [DialogAction.DISCARD, notificationMinutes];
}

Future<DialogAction> genericDialog(BuildContext context,
    {@required Widget child,
    Offset startOffset = const Offset(0.0, 0.0),
    Offset endOffset = const Offset(0.0, 0.0)}) async {
  final action = await showCustomDialog<DialogAction>(context, child,
      startOffset: startOffset, endOffset: endOffset);
  return action ?? DialogAction.DISCARD;
}

Future<T> showCustomDialog<T>(BuildContext context, Widget child,
    {Offset startOffset = const Offset(0.0, 0.0),
    Offset endOffset = const Offset(0.0, 0.0),
    bool createMaterial = true}) async {
  final Alignment startAlignment = Alignment(startOffset.dx, startOffset.dy);
  final Alignment endAlignment = Alignment(endOffset.dx, endOffset.dy);
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        SafeArea(
            child: createMaterial
                ? Material(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0)),
                    color: Theme.of(context).primaryColor,
                    child: child,
                  )
                : child),
    transitionBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.2),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
            child: Align(alignment: endAlignment, child: child),
          ));
    },
    barrierDismissible: true,
    barrierColor: Colors.black26,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 250),
  );
}
