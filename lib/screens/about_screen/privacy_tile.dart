import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class PrivacyTile extends StatelessWidget {
  const PrivacyTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchURL(StaticValues.pocketBusWebSite),
      child: GenericTile(
        title: Localization.of(context).miscPrivacy,
        subtitle: Localization.of(context).miscPrivacy,
        leadingWidget: const Icon(Icons.portrait),
      ),
    );
  }
}
