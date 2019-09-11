import 'package:flutter/material.dart';
import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/notification_bloc.dart';
import 'package:pocket_bus/BloC/schedules_bloc.dart';
import 'package:pocket_bus/BloC/stops_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Misc/custom_tooltip.dart';
import 'package:pocket_bus/Models/favorite_stop.dart';
import 'package:pocket_bus/Models/Foli/schedules_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/Models/notification_model.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:intl/intl.dart';
import 'package:pocket_bus/screens/map_screens/track_map_screen/track_map_frame.dart';
import 'package:url_launcher/url_launcher.dart';

class CenterSpinner extends StatefulWidget {
  const CenterSpinner({Key key}) : super(key: key);

  @override
  _CenterSpinnerState createState() => _CenterSpinnerState();
}

class _CenterSpinnerState extends State<CenterSpinner> {
  @override
  Widget build(BuildContext context) => const ScaleWidget(
      tweenBegin: 0.0,
      tweenEnd: 1.0,
      duration: Duration(milliseconds: 800),
      child: Center(child: CircularProgressIndicator()));
}

class GenericTile extends StatelessWidget {
  const GenericTile(
      {Key key,
      this.leadingWidget,
      this.title,
      this.subtitle,
      this.trailingWidget})
      : super(key: key);

  final Widget leadingWidget;
  final Widget trailingWidget;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: Row(
        children: <Widget>[
          leadingWidget ?? const EmptyBox(),
          Expanded(
            child: ListTile(
              title: Text(
                title ?? '',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              subtitle: Text(
                subtitle ?? '',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black87
                        : Colors.white70),
              ),
            ),
          ),
          trailingWidget ?? const EmptyBox()
        ],
      ),
    );
  }
}

class GenericDialogTitle extends StatelessWidget {
  const GenericDialogTitle({Key key, @required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        title,
        style:
            TextStyle(fontSize: Theme.of(context).textTheme.subhead.fontSize),
      ),
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({Key key, @required this.height}) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Image(
        image: const AssetImage('images/licenses-app-icon.png'),
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

class Space extends StatelessWidget {
  const Space({Key key, this.width = 0.0, this.height = 20.0})
      : super(key: key);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
      );
}

class FavoriteHearth extends StatelessWidget {
  const FavoriteHearth(
      {Key key, @required this.isFavorite, @required this.showAnimations})
      : super(key: key);

  final bool isFavorite;
  final bool showAnimations;

  @override
  Widget build(BuildContext context) {
    String firstAnimation;
    String secondAnimation;

    if (showAnimations) {
      firstAnimation = 'Favorite';
      secondAnimation = 'Unfavorite';
    } else {
      firstAnimation = 'Favoriteidle';
      secondAnimation = 'Unfavoriteidle';
    }

    return SizedBox(
      height: 32,
      width: 32,
      child: FlareActor(
        'images/Hearth.flr',
        alignment: Alignment.center,
        fit: BoxFit.contain,
        animation: isFavorite ? firstAnimation : secondAnimation,
        shouldClip: false,
      ),
    );
  }
}

class SubTile extends StatelessWidget {
  const SubTile({Key key, @required this.currentSchedule}) : super(key: key);
  final Schedule currentSchedule;

  @override
  Widget build(BuildContext context) {
    final DateTime aimedArrivalTime = DateTime.fromMillisecondsSinceEpoch(
        currentSchedule.aimeddeparturetime * 1000);
    final DateTime expectedArrivalTime = DateTime.fromMillisecondsSinceEpoch(
        currentSchedule.expecteddeparturetime * 1000);
    final int scheduleOffsetInMinutes =
        expectedArrivalTime.difference(aimedArrivalTime).inMinutes;
    final int arrivalTimeInMinutes =
        expectedArrivalTime.difference(DateTime.now()).inMinutes;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        BusScheduledText(
          expectedArrivalTime: expectedArrivalTime,
        ),
        BusArrivalMinutes(
          scheduleOffsetInMinutes: scheduleOffsetInMinutes,
          arrivalTimeInMinutes: arrivalTimeInMinutes,
        )
      ],
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({Key key, @required this.currentStop}) : super(key: key);
  final BusStop currentStop;

  @override
  Widget build(BuildContext context) {
    final StopsBloc _stopsBloc = BlocProvider.of<StopsBloc>(context);
    bool isFavorite;
    bool showAnimations = false;
    return Container(
      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CustomTooltip(
                message: Localization.of(context).miscSchedulesUpdated,
                child: const Icon(
                  Icons.info_outline,
                )),
            StopDetails(
              currentStop: currentStop,
            ),
            StreamBuilder<List<FavoriteStop>>(
                stream: _stopsBloc.outFavorites,
                builder: (context, snapshot) {
                  isFavorite = _stopsBloc.isFavorite(currentStop);
                  return GestureDetector(
                    onTap: () {
                      _stopsBloc.handleFavoriteTap(currentStop);
                      showAnimations = true;
                    },
                    child: FavoriteHearth(
                        isFavorite: isFavorite, showAnimations: showAnimations),
                  );
                }),
          ]),
    );
  }
}

class StopDetails extends StatelessWidget {
  const StopDetails(
      {Key key, @required this.currentStop, this.centerStopDetailsText = true})
      : super(key: key);
  final BusStop currentStop;
  final bool centerStopDetailsText;

  @override
  Widget build(BuildContext context) {
    final String fullName =
        '${currentStop.stopName} ${Localization.of(context).miscStopNo}. ${currentStop.busStopCode}';
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      child: Text('${currentStop.customName ?? fullName}',
          textAlign: centerStopDetailsText ? TextAlign.center : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.subhead.fontSize)),
    );
  }
}

class DestinationText extends StatelessWidget {
  const DestinationText({Key key, @required this.currentSchedule})
      : super(key: key);
  final Schedule currentSchedule;

  @override
  Widget build(BuildContext context) {
    return Text(currentSchedule.destinationdisplay);
  }
}

class BusScheduledText extends StatelessWidget {
  const BusScheduledText({Key key, @required this.expectedArrivalTime})
      : super(key: key);
  final DateTime expectedArrivalTime;

  @override
  Widget build(BuildContext context) => Text(
        '${Localization.of(context).miscScheduled} ${DateFormat('kk:mm').format(expectedArrivalTime)}',
        style: const TextStyle(fontWeight: FontWeight.normal),
      );
}

class BusArrivalMinutes extends StatelessWidget {
  const BusArrivalMinutes(
      {Key key,
      @required this.arrivalTimeInMinutes,
      @required this.scheduleOffsetInMinutes})
      : super(key: key);
  final int arrivalTimeInMinutes;
  final int scheduleOffsetInMinutes;

  @override
  Widget build(BuildContext context) {
    final SchedulesBloc _schedulesBloc =
        BlocProvider.of<SchedulesBloc>(context);

    final Widget _arrivalMinutes = arrivalTimeInMinutes <= 60
        ? Row(
            children: <Widget>[
              if (arrivalTimeInMinutes != 0)
                Text(
                  '$arrivalTimeInMinutes min ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (arrivalTimeInMinutes != 0 && scheduleOffsetInMinutes != 0)
                Text(
                  scheduleOffsetInMinutes.isNegative
                      ? '($scheduleOffsetInMinutes)'
                      : '(+$scheduleOffsetInMinutes)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheduleOffsetInMinutes.isNegative
                          ? Colors.green
                          : Colors.red),
                ),
            ],
          )
        : const EmptyBox();

    return StreamBuilder<bool>(
        stream: _schedulesBloc.outLoading,
        builder: (context, snapshot) {
          final Widget buildWidget = snapshot.hasData && snapshot.data
              ? const MiniLoader()
              : _arrivalMinutes;
          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: buildWidget,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(child: child, scale: animation));
        });
  }
}

class MiniLoader extends StatelessWidget {
  const MiniLoader({Key key, this.valueColor}) : super(key: key);
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(valueColor),
      ),
      height: 15.0,
      width: 15.0,
    );
  }
}

class ScheduleAndMapButtons extends StatelessWidget {
  const ScheduleAndMapButtons(
      {Key key, @required this.currentSchedule, @required this.currentStop})
      : super(key: key);

  final Schedule currentSchedule;
  final BusStop currentStop;

  @override
  Widget build(BuildContext context) {
    final NotificationBloc _notificationBloc =
        BlocProvider.of<NotificationBloc>(context);
    final DateTime expectedArrivalTime = DateTime.fromMillisecondsSinceEpoch(
        currentSchedule.expecteddeparturetime * 1000);

    final int arrivalTimeInMinutes =
        expectedArrivalTime.difference(DateTime.now()).inMinutes;

    final bool greyAlarmButton = arrivalTimeInMinutes >=
        10; //Enable alarm button only if there >= 5´10 minutes before arrival. Minimum alarm time if 5 minutes

    void _handleAlarm(DialogAction favoriteDialogAction,
        int minutesBeforeArrival, DateTime expectedArrivalTime) {
      final NotificationModel notificationModel = NotificationModel(
          selectedMinutes: minutesBeforeArrival,
          schedule: currentSchedule,
          stopData: currentStop,
          notificationTime: expectedArrivalTime
              .subtract(Duration(minutes: minutesBeforeArrival)));

      switch (favoriteDialogAction) {
        case DialogAction.APPLY:
          _notificationBloc.addNotification(notificationModel);
          break;
        case DialogAction.REMOVE:
          _notificationBloc.removeNotification(notificationModel);
          break;
        case DialogAction.DISCARD:
          break;
        default:
          break;
      }
    }

    return ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.explore,
                ),
                Text(
                  ' ${Localization.of(context).miscRoute}',
                ),
              ],
            ),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TrackMapFrame(
                          currentStop: currentStop,
                          schedule: currentSchedule,
                        )),
              );
            },
          ),
          StreamBuilder<List<NotificationModel>>(
              stream: _notificationBloc.outNotifications,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CenterSpinner();
                }

                final NotificationModel notificationModel = NotificationModel(
                    schedule: currentSchedule, stopData: currentStop);

                final Widget setAlarmButton = RaisedButton(
                    key: const ValueKey(1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.notifications),
                        Text(
                          ' ${Localization.of(context).miscAlarm}',
                        ),
                      ],
                    ),
                    color: Theme.of(context).accentColor,
                    elevation: 4.0,
                    onPressed: greyAlarmButton
                        ? () {
                            alarmDialog(context, arrivalTimeInMinutes)
                                .then((values) {
                              _handleAlarm(
                                  values[0], values[1], expectedArrivalTime);
                            });
                          }
                        : null);

                final Widget cancelAlarmButton = RaisedButton(
                    key: const ValueKey(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.notifications_off),
                        Text(' ${Localization.of(context).miscAlarm}'),
                      ],
                    ),
                    color: Colors.red[900],
                    elevation: 4.0,
                    onPressed: () => _notificationBloc
                        .removeNotification(notificationModel));

                final bool alarmEnabled =
                    _notificationBloc.isAlarm(notificationModel);

                final Widget button =
                    alarmEnabled ? cancelAlarmButton : setAlarmButton;

                return CustomTooltip(
                    enabled: !greyAlarmButton && !alarmEnabled,
                    message: 'Run, Forrest, Run!',
                    child: AnimatedSwitcher(
                      child: button,
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.decelerate,
                    ));
              })
        ]);
  }
}

class NoBuses extends StatelessWidget {
  const NoBuses({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              style: Theme.of(context).brightness == Brightness.dark
                  ? BorderStyle.none
                  : BorderStyle.solid),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          )),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Space(),
              const Center(
                child: Text(
                  '😴',
                  style: TextStyle(fontSize: 50),
                ),
              ),
              const Space(),
              Text(
                Localization.of(context).scheduleSheetNoBusesTitle,
              ),
              const Space(
                height: 10.0,
              ),
              Text(
                Localization.of(context).scheduleSheetNoBusesBody,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusNumberChip extends StatelessWidget {
  const BusNumberChip({Key key, @required this.lineRef}) : super(key: key);
  final String lineRef;

  @override
  Widget build(BuildContext context) {
    return Chip(
        backgroundColor: Theme.of(context).accentColor,
        label: Text(
          lineRef,
          style: const TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
        ));
  }
}

class BusIcon extends StatelessWidget {
  const BusIcon({Key key, @required this.height}) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: const AssetImage('images/icons8-bus-48.png'),
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class BikeIcon extends StatelessWidget {
  const BikeIcon({Key key, @required this.height}) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: const AssetImage('images/icons8-bicycle-48.png'),
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class EmptyBox extends StatelessWidget {
  const EmptyBox({Key key, this.height = 0, this.width = 0}) : super(key: key);
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}

class BouncyWidget extends StatefulWidget {
  const BouncyWidget(
      {Key key,
      @required this.child,
      this.tweenBegin = 1.0,
      this.tweenEnd = 1.2,
      @required this.duration})
      : super(key: key);
  final Widget child;
  final double tweenBegin;
  final double tweenEnd;
  final Duration duration;

  @override
  _BouncyWidgetState createState() => _BouncyWidgetState();
}

class _BouncyWidgetState extends State<BouncyWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = Tween<double>(
            begin: widget.tweenBegin, end: widget.tweenEnd)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            }
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _scaleAnimation,
        child: widget.child,
        builder: (BuildContext context, Widget child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child));
  }
}

class ScaleWidget extends StatefulWidget {
  const ScaleWidget(
      {Key key,
      @required this.child,
      this.tweenBegin = 0.0,
      this.tweenEnd = 1.0,
      @required this.duration})
      : super(key: key);

  final Widget child;
  final double tweenBegin;
  final double tweenEnd;
  final Duration duration;

  @override
  _ScaleWidgetState createState() => _ScaleWidgetState();
}

class _ScaleWidgetState extends State<ScaleWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = Tween<double>(
            begin: widget.tweenBegin, end: widget.tweenEnd)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _scaleAnimation,
        child: widget.child,
        builder: (BuildContext context, Widget child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child));
  }
}

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
