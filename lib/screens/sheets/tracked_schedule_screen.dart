import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/schedules_bloc.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/Foli/schedules_data.dart';
import 'package:pocket_bus/Models/Foli/stops_data.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrackedScheduleScreen extends StatefulWidget {
  const TrackedScheduleScreen(
      {Key key,
      @required this.currentStop,
      @required this.trackedTripReference})
      : super(key: key);
  final BusStop currentStop;

  ///trackedTripReference is used to move Tracked Bus schedule to top of the scheduleList.
  ///Used in TrackMapScreen ScheduleTile
  final String trackedTripReference;

  @override
  _TrackedScheduleScreenState createState() => _TrackedScheduleScreenState();
}

class _TrackedScheduleScreenState extends State<TrackedScheduleScreen> {
  SchedulesBloc _schedulesBloc;

  @override
  void initState() {
    super.initState();
    _schedulesBloc ??= BlocProvider.of<SchedulesBloc>(context);
    _handleScheduleRefresh();

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
  void dispose() {
    _schedulesBloc?.cancelTrackedScheduleTimer();
    SystemChannels.lifecycle.setMessageHandler(null);
    super.dispose();
  }

  Future<void> _handleScheduleRefresh() async {
    await _schedulesBloc.refreshTrackedSchedules(
        widget.currentStop, widget.trackedTripReference);
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
          return ScheduleTile(
              currentSchedule: currentSchedule,
              currentStop: widget.currentStop,
              tripRef: widget.trackedTripReference);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size _contextSize = MediaQuery.of(context).size;
    return ClipPath(
      clipper: NotchClipper(Rect.fromCircle(
          center: Offset(_contextSize.width / 2.0, 0), radius: 6.0)),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        height: _contextSize.height / 1.965,
        child: Column(
          children: <Widget>[
            TopBar(
              currentStop: widget.currentStop,
            ),
            Expanded(
              child: StreamBuilder<ScheduleData>(
                  stream: _schedulesBloc.outTrackedSchedules,
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

class ScheduleTile extends StatelessWidget {
  const ScheduleTile(
      {Key key,
      @required this.currentSchedule,
      @required this.currentStop,
      this.tripRef})
      : super(key: key);

  final Schedule currentSchedule;
  final BusStop currentStop;
  final String tripRef;

  @override
  Widget build(BuildContext context) {
    final String trackedTripRef = currentSchedule.tripref;
    final bool trackedBus = trackedTripRef == tripRef;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
                color: Theme.of(context).accentColor,
                width: 1.0,
                style: trackedBus ? BorderStyle.solid : BorderStyle.none)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
            leading: BusNumberChip(
              lineRef: currentSchedule.lineref,
            ),
            title: DestinationText(
              currentSchedule: currentSchedule,
            ),
            subtitle: SubTile(
              currentSchedule: currentSchedule,
            ),
          ),
        ),
      ),
    );
  }
}
