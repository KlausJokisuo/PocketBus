import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/notification_bloc.dart';
import 'package:pocket_bus/BloC/schedules_bloc.dart';
import 'package:pocket_bus/Misc/custom_expansion_tile.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/Foli/schedules_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';

import 'package:pocket_bus/Theme/themes.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScheduleScreen extends StatefulWidget {
  const MainScheduleScreen({
    Key key,
    @required this.currentStop,
    @required this.showTopBar,
  }) : super(key: key);
  final BusStop currentStop;

  //Option to showTopBar (Favorites hearth etc). This is also used to check if we are showing Widget in ScheduleSheet or in FavoriteSheet
  final bool showTopBar;

  @override
  _MainScheduleScreenState createState() => _MainScheduleScreenState();
}

class _MainScheduleScreenState extends State<MainScheduleScreen> {
  Size _contextSize;
  NotificationBloc _notificationBloc;
  SchedulesBloc _schedulesBloc;

  @override
  void initState() {
    super.initState();

    SystemChannels.lifecycle.setMessageHandler((msg) {
      //If we resume application and we have ScheduleScreen showing do refresh
      if (msg == AppLifecycleState.resumed.toString()) {
        debugPrint('refresh');
        _handleScheduleRefresh();
      }
      return;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contextSize = MediaQuery.of(context).size;
    _notificationBloc ??= BlocProvider.of<NotificationBloc>(context);
    _schedulesBloc ??= BlocProvider.of<SchedulesBloc>(context);

    _notificationBloc.loadNotifications();

    _handleScheduleRefresh();
  }

  @override
  void dispose() {
    _schedulesBloc?.cancelScheduleTimer();
    SystemChannels.lifecycle.setMessageHandler(null);
    super.dispose();
  }

  Future<void> _handleScheduleRefresh() async {
    await _schedulesBloc.refreshSchedules(widget.currentStop);
  }

  Widget _scheduleListBuilder(
      int itemCount, AsyncSnapshot<ScheduleData> snapshot) {
    return RefreshIndicator(
      onRefresh: _handleScheduleRefresh,
      color: Colors.black,
      backgroundColor: Theme.of(context).accentColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final Schedule currentSchedule = snapshot.data.schedules[index];
          return ScheduleTileExpanded(
            currentSchedule: currentSchedule,
            currentStop: widget.currentStop,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: NotchClipper(Rect.fromCircle(
          center: Offset(_contextSize.width / 2.0, 0.0),
          radius: widget.showTopBar ? 6 : 0)),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        //Change widget height depending if the widget is used in FavoriteSheet or SchedulesSheet
        height: widget.showTopBar
            ? _contextSize.height / 1.965
            : _contextSize.height / 2.7,
        child: Column(
          children: <Widget>[
            if (widget.showTopBar) TopBar(currentStop: widget.currentStop),
            Expanded(
              child: StreamBuilder<ScheduleData>(
                  stream: _schedulesBloc.outSchedules,
                  builder: (context, snapshot) {
                    Widget buildWidget;

                    if (!snapshot.hasData) {
                      buildWidget = const SizedBox.expand(
                        child: CenterSpinner(),
                      );
                    } else {
                      final int scheduleCount = snapshot.data.schedules.length;
                      buildWidget = scheduleCount != 0
                          ? _scheduleListBuilder(scheduleCount, snapshot)
                          : const NoBuses();
                    }
                    return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: buildWidget);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleTileExpanded extends StatelessWidget {
  const ScheduleTileExpanded(
      {Key key, @required this.currentSchedule, @required this.currentStop})
      : super(key: key);

  final Schedule currentSchedule;
  final BusStop currentStop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
            bottomLeft: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 0.1,
              offset: const Offset(0, 0.1),
              color: darkTheme
                  .primaryColor, //Pretty much only affects in Light theme
            ),
          ],
        ),
        child: CustomExpansionTile(
          backgroundColor: Theme.of(context).cardColor,
          title: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
              leading: BusNumberChip(
                lineRef: currentSchedule.lineref,
              ),
              title: DestinationText(
                currentSchedule: currentSchedule,
              ),
              subtitle: SubTile(
                currentSchedule: currentSchedule,
              )),
          children: <Widget>[
            ScheduleAndMapButtons(
              currentSchedule: currentSchedule,
              currentStop: currentStop,
            )
          ],
        ),
      ),
    );
  }
}
