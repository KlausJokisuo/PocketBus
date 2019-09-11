import 'package:pocket_bus/BloC/bloc_provider.dart';

import 'package:pocket_bus/BloC/settings_bloc.dart';
import 'package:pocket_bus/Dialogs/dialogs.dart';
import 'package:pocket_bus/Misc/utility.dart';
import 'package:pocket_bus/Models/settingsData.dart';
import 'package:pocket_bus/Screens/shared_widgets.dart';
import 'package:pocket_bus/localizations.dart';
import 'package:flutter/material.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final Map<String, String> languageMap = {
      'en': Localization.of(context).languageOptionEn,
      'fi': Localization.of(context).languageOptionFi
    };
    return StreamBuilder<Settings>(
        stream: _settingsBloc.outSettings.distinct((previousValue, nextValue) =>
            previousValue.languageCode == nextValue.languageCode),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenterSpinner();
          }

          final String languageCode =
              Localizations.localeOf(context).languageCode;

          TapDownDetails tapDetails;

          return InkWell(
            onTapDown: (TapDownDetails details) => tapDetails = details,
            onTap: () {
              final Offset startOffset = offsetFromCoordinates(
                  tapDetails.globalPosition.dx,
                  tapDetails.globalPosition.dy,
                  context);
              return genericDialog(context,
                  child: LanguageOptions(languageCode: languageCode));
            },
            child: GenericTile(
              title: Localization.of(context).languageSettingsTitle,
              subtitle: '${languageMap[languageCode]}',
              leadingWidget: const Icon(Icons.language),
            ),
          );
        });
  }
}

class LanguageOptions extends StatelessWidget {
  const LanguageOptions({Key key, @required this.languageCode})
      : super(key: key);
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.18,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: <Widget>[
          GenericDialogTitle(
            title: Localization.of(context).languageSettingsTitle,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              EnglishTile(
                languageCode: languageCode,
              ),
              FinnishTile(
                languageCode: languageCode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EnglishTile extends StatelessWidget {
  const EnglishTile({Key key, @required this.languageCode}) : super(key: key);
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      onTap: () {
        Navigator.pop(context);
        _settingsBloc.changeSetting(languageCode: 'en');
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20.0, right: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Text('🇬🇧'),
            ),
            Text(
              Localization.of(context).languageOptionEn,
            ),
            languageCode == 'en'
                ? const BouncyWidget(
                    child: Icon(
                      Icons.check,
                      size: 25,
                    ),
                    tweenBegin: 1.0,
                    tweenEnd: 1.3,
                    duration: Duration(milliseconds: 400),
                  )
                : const EmptyBox(
                    width: 25,
                  )
          ],
        ),
      ),
    );
  }
}

class FinnishTile extends StatelessWidget {
  const FinnishTile({Key key, @required this.languageCode}) : super(key: key);
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final SettingsBloc _settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      onTap: () {
        _settingsBloc.changeSetting(languageCode: 'fi');
        Navigator.pop(context);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20.0, right: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Text('🇫🇮'),
            ),
            Text(
              Localization.of(context).languageOptionFi,
            ),
            languageCode == 'fi'
                ? const BouncyWidget(
                    child: Icon(
                      Icons.check,
                      size: 25,
                    ),
                    tweenBegin: 1.0,
                    tweenEnd: 1.3,
                    duration: Duration(milliseconds: 400),
                  )
                : const EmptyBox(
                    width: 25,
                  )
          ],
        ),
      ),
    );
  }
}
