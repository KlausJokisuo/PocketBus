import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/notification_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/notification_model.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TapDownDetails tapDetails;
    return InkWell(
      onTapDown: (TapDownDetails details) => tapDetails = details,
      onTap: () {
        final Offset startOffset = offsetFromCoordinates(
            tapDetails.globalPosition.dx,
            tapDetails.globalPosition.dy,
            context);
        return genericDialog(context, child: const NotificationsList());
      },
      child: GenericTile(
        title: Localization.of(context).notificationSettingsTitle,
        subtitle: Localization.of(context).notificationSettingsSubtitle,
        leadingWidget: const Icon(Icons.notifications),
      ),
    );
  }
}

class NotificationsList extends StatefulWidget {
  const NotificationsList({Key key}) : super(key: key);

  @override
  _NotificationsListState createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc ??= BlocProvider.of<NotificationBloc>(context);
    _notificationBloc.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.8,
        child: StreamBuilder<List<NotificationModel>>(
            stream: _notificationBloc.outNotifications,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CenterSpinner();
              }
              return Column(
                children: <Widget>[
                  GenericDialogTitle(
                    title: Localization.of(context).notificationSettingsTitle,
                  ),
                  Expanded(
                    child: snapshot.data.isEmpty
                        ? const BouncyWidget(
                            child: Icon(
                              Icons.notifications_off,
                              size: 120,
                            ),
                            duration: Duration(milliseconds: 500),
                          )
                        : Scrollbar(
                            child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Divider(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white),
                              );
                            },
                            itemBuilder: (context, index) {
                              final NotificationModel notificationModel =
                                  snapshot.data[index];
                              return ListTile(
                                leading: BusNumberChip(
                                  lineRef: notificationModel.schedule.lineref,
                                ),
                                title: Text(
                                    '${Localization.of(context).miscStopNo}. ${notificationModel.stopData.busStopCode}\n${notificationModel.stopData.customName ?? notificationModel.stopData.stopName}'),
                                subtitle: Text(
                                    '${Localization.of(context).miscTime} ${DateFormat('kk:mm').format(notificationModel.notificationTime)} '),
                                trailing: InkWell(
                                  child: Icon(
                                    Icons.delete,
                                    size: 32,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onTap: () => _notificationBloc
                                      .removeNotification(notificationModel),
                                ),
                              );
                            },
                          )),
                  ),
                ],
              );
            }));
  }
}
