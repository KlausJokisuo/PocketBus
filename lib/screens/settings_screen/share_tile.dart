import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';

class ShareTile extends StatelessWidget {
  const ShareTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Share.share(StaticValues.playStoreUrl,
            subject: '${StaticValues.appName} 😍'),
        child: GenericTile(
          title: Localization.of(context).shareSettingsTitle,
          subtitle: Localization.of(context).shareSettingsSubtitle,
          leadingWidget: const Icon(Icons.share),
        ));
  }
}
