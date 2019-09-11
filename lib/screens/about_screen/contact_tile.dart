import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchURL(
          'mailto:${StaticValues.authorEmail}?subject=${Localization.of(context).miscEmailSubject}'),
      child: GenericTile(
        title: Localization.of(context).aboutContactTitle,
        subtitle: Localization.of(context).aboutContactSubtitle,
        leadingWidget: const Icon(Icons.email),
      ),
    );
  }
}
