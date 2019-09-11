import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class AboutTile extends StatelessWidget {
  const AboutTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/about'),
      child: GenericTile(
        title: Localization.of(context).aboutSettingsTitle,
        subtitle: Localization.of(context).aboutSettingsSubtitle,
        leadingWidget: const Icon(Icons.info),
      ),
    );
  }
}
