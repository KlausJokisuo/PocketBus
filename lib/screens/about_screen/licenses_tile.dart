import 'dart:async';

import 'dart:developer' show Timeline, Flow;
import 'dart:io';

import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Flow;
import 'package:flutter/material.dart' hide Flow;

import 'package:pocket_bus/StaticValues.dart';

class LicensesTile extends StatelessWidget {
  const LicensesTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showLicensePage(
          context: context,
          applicationName: StaticValues.appName,
          applicationVersion:
              '${Localization.of(context).miscVersion} ${StaticValues.version}',
          applicationIcon: const AppIcon(
            height: 100,
          )),
      child: GenericTile(
        title: Localization.of(context).licensesSettingsTitle,
        subtitle: 'The real heroes here',
        leadingWidget: const Icon(Icons.all_inclusive),
      ),
    );
  }
}

void _showLicensePage({
  @required BuildContext context,
  String applicationName,
  String applicationVersion,
  Widget applicationIcon,
  String applicationLegalese,
}) {
  assert(context != null);
  Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => LicensePage(
                applicationName: applicationName,
                applicationIcon: applicationIcon,
                applicationVersion: applicationVersion,
                applicationLegalese: applicationLegalese,
              )));
}

class LicensePage extends StatefulWidget {
  /// Creates a page that shows licenses for software used by the application.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version and legalese values
  /// default to the empty string.
  ///
  /// The licenses shown on the [LicensePage] are those returned by the
  /// [LicenseRegistry] API, which can be used to add more licenses to the list.
  const LicensePage(
      {Key key,
      this.applicationName,
      this.applicationVersion,
      this.applicationLegalese,
      this.applicationIcon})
      : super(key: key);

  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String applicationName;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name.
  ///
  /// Defaults to the empty string.
  final String applicationVersion;

  /// A string to show in small print.
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String applicationLegalese;

  final Widget applicationIcon;

  @override
  _LicensePageState createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  @override
  void initState() {
    super.initState();
    _initLicenses();
  }

  final List<Widget> _licenses = <Widget>[];
  bool _loaded = false;

  Future<void> _initLicenses() async {
    int debugFlowId = -1;
    assert(() {
      final Flow flow = Flow.begin();
      Timeline.timeSync('_initLicenses()', () {}, flow: flow);
      debugFlowId = flow.id;
      return true;
    }());
    await for (final LicenseEntry license in LicenseRegistry.licenses) {
      if (!mounted) {
        return;
      }
      assert(() {
        Timeline.timeSync('_initLicenses()', () {},
            flow: Flow.step(debugFlowId));
        return true;
      }());
      final List<LicenseParagraph> paragraphs =
          await SchedulerBinding.instance.scheduleTask<List<LicenseParagraph>>(
        license.paragraphs.toList,
        Priority.animation,
        debugLabel: 'License',
      );
      if (mounted) {
        setState(() {
          _licenses.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0),
            child: Text(
              '🍀‬',
              // That's U+1F340. Could also use U+2766 (❦) if U+1F340 doesn't work everywhere.
              textAlign: TextAlign.center,
            ),
          ));
          _licenses.add(Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 0.0))),
            child: Text(
              license.packages.join(', '),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ));
          for (final LicenseParagraph paragraph in paragraphs) {
            if (paragraph.indent == LicenseParagraph.centeredIndent) {
              _licenses.add(Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  paragraph.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ));
            } else {
              assert(paragraph.indent >= 0);
              _licenses.add(Padding(
                padding: EdgeInsetsDirectional.only(
                    top: 8.0, start: 16.0 * paragraph.indent),
                child: Text(paragraph.text),
              ));
            }
          }
        });
      }
    }
    setState(() {
      _loaded = true;
    });
    assert(() {
      Timeline.timeSync('Build scheduled', () {}, flow: Flow.end(debugFlowId));
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final String name = widget.applicationName;
    final String version = widget.applicationVersion;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<Widget> contents = <Widget>[
      Text(name,
          style: Theme.of(context).textTheme.headline,
          textAlign: TextAlign.center),
      widget.applicationIcon,
      Text(version,
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.center),
      Container(height: 18.0),
      Text(widget.applicationLegalese ?? '',
          style: Theme.of(context).textTheme.caption,
          textAlign: TextAlign.center),
      Container(height: 18.0),
      Text('Powered by Flutter',
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.center),
      Container(height: 24.0),
    ];
    contents.addAll(_licenses);
    if (!_loaded) {
      contents.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.licensesPageTitle),
      ),
      // All of the licenses page text is English. We don't want localized text
      // or text direction.
      body: Localizations.override(
        locale: const Locale('en', 'US'),
        context: context,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: SafeArea(
            bottom: false,
            child: Scrollbar(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                children: contents,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
