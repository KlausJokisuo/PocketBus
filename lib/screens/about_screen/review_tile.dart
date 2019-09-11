import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/StaticValues.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => LaunchReview.launch(
            androidAppId: StaticValues.packageName, iOSAppId: ''),
        child: GenericTile(
          title: Localization.of(context).reviewSettingsTitle,
          subtitle: Localization.of(context).reviewSettingsSubtitle,
          leadingWidget: const Icon(Icons.favorite),
        ));
  }
}
