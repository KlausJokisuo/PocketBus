import 'dart:async';

import 'package:pocket_bus/BloC/bloc_provider.dart';
import 'package:pocket_bus/BloC/bloc_provider_tree.dart';
import 'package:pocket_bus/BloC/bus_tracking_bloc.dart';
import 'package:pocket_bus/BloC/notification_bloc.dart';
import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/BloC/stops_bloc.dart';
import 'package:pocket_bus/BloC/follari_bloc.dart';
import 'package:pocket_bus/BloC/schedules_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Screens/about_screen/about_screen.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/Theme/themes.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocket_bus/screens/map_screens/main_map_screen/main_map_frame.dart';
import 'package:pocket_bus/screens/settings_screen/settings_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Models/settingsData.dart';
import 'StaticValues.dart';

class PocketBus extends StatefulWidget {
  @override
  _PocketBusState createState() => _PocketBusState();
}

class _PocketBusState extends State<PocketBus> {
  final SettingsBloc _settingsBloc = SettingsBloc();

  final NotificationBloc _notificationBloc = NotificationBloc();

  final StopsBloc _stopsBloc = StopsBloc();

  final SchedulesBloc _schedulesBloc = SchedulesBloc();

  final FollariBloc _follariBloc = FollariBloc();

  final BusTrackingBloc _busTrackingBloc = BusTrackingBloc();

  @override
  void dispose() {
    _settingsBloc?.dispose();
    _notificationBloc?.dispose();
    _stopsBloc?.dispose();
    _follariBloc?.dispose();
    _busTrackingBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(blocProviders: [
      BlocProvider<SettingsBloc>(bloc: _settingsBloc),
      BlocProvider<NotificationBloc>(bloc: _notificationBloc),
      BlocProvider<StopsBloc>(bloc: _stopsBloc),
      BlocProvider<SchedulesBloc>(bloc: _schedulesBloc),
      BlocProvider<FollariBloc>(
        bloc: _follariBloc,
      ),
      BlocProvider<BusTrackingBloc>(bloc: _busTrackingBloc),
    ], child: const InitApp());
  }
}

class InitApp extends StatefulWidget {
  const InitApp({Key key}) : super(key: key);

  @override
  _InitAppState createState() => _InitAppState();
}

class _InitAppState extends State<InitApp> {
  SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc ??= BlocProvider.of<SettingsBloc>(context);
    _settingsBloc.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Settings>(
        stream: _settingsBloc.outSettings.distinct((previousValue, nextValue) =>
            previousValue.mapType == nextValue.mapType &&
            previousValue.themeToUse == nextValue.themeToUse &&
            previousValue.languageCode == nextValue.languageCode),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenterSpinner();
          }

          debugPrint('Building InitApp();');
          final _currentStyle = SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: snapshot.data.mapType == MapType.normal
                  ? darkTheme.brightness
                  : lightTheme.brightness);

          return MaterialApp(
              darkTheme: darkTheme,
              locale: snapshot.data.languageCode.isEmpty
                  ? null
                  : Locale(snapshot.data.languageCode),
              localizationsDelegates: const [
                LocalizationDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('fi', ''),
              ],
              title: StaticValues.appName,
              debugShowCheckedModeBanner: false,
              theme: availableThemes[snapshot.data.themeToUse.index],
              routes: {
                '/settings': (context) => const SettingsScreen(),
                '/about': (context) => const AboutScreen(),
              },
              home: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: _currentStyle, sized: false, child: const AppHome()));
        });
  }
}

class AppHome extends StatefulWidget {
  const AppHome({Key key}) : super(key: key);

  @override
  AppHomeState createState() {
    return AppHomeState();
  }
}

class AppHomeState extends State<AppHome> {
  StopsBloc _stopsBloc;
  FollariBloc _follariBloc;
  SettingsBloc _settingsBloc;
  Stream<ConnectivityResult> connectivityResultStream;

  @override
  void initState() {
    super.initState();
    _settingsBloc ??= BlocProvider.of<SettingsBloc>(context);
    _stopsBloc ??= BlocProvider.of<StopsBloc>(context);
    _follariBloc ??= BlocProvider.of<FollariBloc>(context);
    connectivityResultStream ??= Connectivity().onConnectivityChanged;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
        stream: connectivityResultStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenterSpinner();
          }
          if (snapshot.data == ConnectivityResult.none) {
            _noConnection();
          }

          return StreamBuilder<List<dynamic>>(
              stream: ZipStream(
                [
                  _stopsBloc.outStops,
                  _stopsBloc.outFavorites,
                  _follariBloc.outRacks,
                  _follariBloc.outFavorites,
                ],
                (data) => data,
              ),
              builder: (context, snapshot) {
                final Widget buildWidget = !snapshot.hasData
                    ? const CenterSpinner()
                    : const MainMapFrame();

                return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: buildWidget);
              });
        });
  }

  void _loadData() {
    debugPrint('_loadData();');
    _stopsBloc.getStops();
    _stopsBloc.loadFavorites();
    _follariBloc.getAllRacks();
    _follariBloc.loadFavorites();
  }

  void _noConnection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      noConnectionDialog(context).then((response) {
        if (response == DialogAction.RESET) {
          setState(_loadData);
        }
      });
    });
  }
}
