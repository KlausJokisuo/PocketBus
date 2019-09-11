import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class SourceSettings extends StatelessWidget {
  const SourceSettings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchURL(StaticValues.gitHub),
      child: GenericTile(
        leadingWidget: const Icon(Icons.code),
        title: 'GitHub',
        subtitle: Localization.of(context).githubSettingsSubtitle,
      ),
    );
  }
}
