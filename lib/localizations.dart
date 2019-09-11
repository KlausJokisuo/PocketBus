import 'dart:async';

import 'package:pocket_bus/StaticValues.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Localization {
  Localization(this.locale);

  final Locale locale;

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  final Map<String, Map<String, String>> _localizedValues = {
    'fi': {
      'settings_title': 'Asetukset',
      'settings_markers_title': 'Merkit',
      'settings_markers_both': 'Molemmat',
      'settings_markers_bike': 'Pyörä',
      'settings_markers_bus': 'Bussi',
      'settings_location_title': 'Aloitus Sijainti',
      'settings_location_current': 'Nykyinen',
      'settings_markers_turku': 'Turku, Keskusta',
      'settings_theme_title': 'Teema',
      'settings_themes_light': 'Vaalea Teema',
      'settings_themes_dark': 'Tumma Teema',
      'settings_themes_black': 'Musta Teema',
      'settings_notifications_title': 'Ilmoitukset',
      'settings_notifications_subtitle': 'Tulevat ilmoitukset',
      'settings_language_title': 'Kieli',
      'settings_language_en': 'Englanti',
      'settings_language_fi': 'Suomi',
      'settings_language_fi': 'Suomi',
      'settings_github_subtitle': 'Lähdekoodi',
      'settings_licenses_title': 'Lisenssit',
      'settings_about_title': 'Tietoja',
      'settings_share_title': 'Jaa',
      'settings_share_subtitle': 'Spread the Love! 💕',
      'settings_about_subtitle': 'Ota yhteyttä, Tietosuoja & Lisenssit',
      'about_contact_title': 'Ota yhteyttä',
      'about_contact_subtitle': 'Hello there!',
      'sheets_favoritesheet_title': 'Suosikit',
      'sheets_favoritesheet_no_favorites_title':
          'Sinulla ei ole yhtään suosikkia!',
      'sheets_favoritesheet_no_favorites_subtitle':
          'Voit lisätä niitä painamalla',
      'sheets_schedulesheet_no_buses_title':
          'Ei busseja seuraavaan pariin tuntiin...',
      'sheets_schedulesheet_no_buses_body':
          'Mutta voit aina käyttää pyörää!\nPaina pyörä merkkiä lähelläsi ja tarkasta onko pyöriä saatavilla!',
      'sheets_bikesheet_bikes_title': 'Pyöriä saatavilla',
      'sheets_bikesheet_no_bikes_title': 'Ei pyöriä saatavilla...',
      'sheets_bikesheet_no_bikes_bodyPart1':
          'Mutta onni onnettomuudessa!\n Ainakin siellä on',
      'sheets_bikesheet_no_bikes_bodyPart2': 'tyhjää paikkaa pyörällesi!',
      'dialogs_edit_favorite_title': 'Muokkaa Suosikkia',
      'dialogs_edit_favorite_form_title': 'Pysäkin Nimi',
      'dialogs_edit_favorite_form_hint': 'esim. Kotipysäkki',
      'dialogs_edit_favorite_form_warning': 'Pysäkin nimi ei voi olla tyhjä',
      'dialogs_connection_warning':
          'Näyttää siltä että sinulla ei ole verkkoyhteyttä päällä puhelimessasi. Laita verkkoyhteys päälle ja käytä taianomaista päivitä nappia kokeillaksesi uudelleen!',
      'dialogs_location_warning': 'Ota sijaintioikeudet käyttöön',
      'dialogs_location_warning_button': 'Avaa Asetukset',
      'misc_time': 'Aika',
      'misc_scheduled': 'Saapumisaika',
      'misc_schedules_updated': 'Aikataulut päivittyvät automaattisesti',
      'misc_bus_location_updated':
          'Bussin sijantitiedot päivittyvät automaattisesti',
      'misc_bus_notification_arrival': 'Ilmoitus ennen bussin saapumista',
      'misc_stopNo': 'Pysäkki Nro',
      'misc_version': 'Versio',
      'misc_search': 'Haku',
      'misc_refresh': 'Päivitä',
      'misc_quit': 'Sulje',
      'misc_apply': 'Tallenna',
      'misc_discard': 'Hylkää',
      'misc_alarm': 'Ilmoitus',
      'misc_cancel': 'Peruuta',
      'misc_route': 'Reitti',
      'settings_review_title': 'Arvostele',
      'settings_review_subtitle': 'Gimme the Stars! ⭐',
      'misc_privacy': 'Tietosuoja',
      'misc_feedback_email_subject': '${StaticValues.appName} - palaute',
    },
    'en': {
      'settings_title': 'Settings',
      'settings_markers_title': 'Markers',
      'settings_markers_both': 'Both',
      'settings_markers_bike': 'Bike',
      'settings_markers_bus': 'Bus',
      'settings_location_title': 'Start Location',
      'settings_location_current': 'Current',
      'settings_markers_turku': 'Turku, Central',
      'settings_theme_title': 'Theme',
      'settings_themes_light': 'Light Theme',
      'settings_themes_dark': 'Dark Theme',
      'settings_themes_black': 'Black Theme',
      'settings_notifications_title': 'Notifications',
      'settings_notifications_subtitle': 'Pending Notifications',
      'settings_language_title': 'Language',
      'settings_language_en': 'English',
      'settings_language_fi': 'Finnish',
      'settings_github_subtitle': 'Source code',
      'settings_licenses_title': 'Licenses',
      'settings_about_title': 'About',
      'settings_share_title': 'Share',
      'settings_share_subtitle': 'Spread the Love! 💕',
      'settings_about_subtitle': 'Contact, Privacy Policy & Licenses',
      'about_contact_title': 'Contact',
      'about_contact_subtitle': 'Hello there!',
      'sheets_favoritesheet_title': 'Favorites',
      'sheets_favoritesheet_no_favorites_title':
          'Looks like you have no favorites!',
      'sheets_favoritesheet_no_favorites_subtitle':
          'You can add them by tapping',
      'sheets_schedulesheet_no_buses_title':
          'No buses for the next few hours...',
      'sheets_schedulesheet_no_buses_body':
          'But you could always use a bike!\nJust tap a bike marker near you and check if there’re bikes available!',
      'sheets_bikesheet_bikes_title': 'Bikes available',
      'sheets_bikesheet_no_bikes_title': 'No bikes available...',
      'sheets_bikesheet_no_bikes_bodyPart1':
          'But on the bright side!\nThere are',
      'sheets_bikesheet_no_bikes_bodyPart2':
          'empty slots available for your bike!',
      'dialogs_edit_favorite_title': 'Edit Favorite',
      'dialogs_edit_favorite_form_title': 'Stop Name',
      'dialogs_edit_favorite_form_hint': 'eg. Home stop',
      'dialogs_edit_favorite_form_warning': 'Stop name can’t be empty',
      'dialogs_connection_warning':
          'It seems like you haven’t enabled data on your phone.\nEnable mobile data / WiFi and use magical refresh button to try again!',
      'dialogs_location_warning': 'Enable location permissions',
      'dialogs_location_warning_button': 'Open Settings',
      'misc_time': 'Time',
      'misc_schedules_updated': 'Schedules are updated automatically',
      'misc_bus_location_updated':
          'Bus location information is updated automatically',
      'misc_bus_notification_arrival': 'Notification before bus arrival',
      'misc_scheduled': 'Scheduled',
      'misc_stopNo': 'Stop No',
      'misc_version': 'Version',
      'misc_search': 'Search',
      'misc_refresh': 'Refresh',
      'misc_quit': 'Quit',
      'misc_apply': 'Apply',
      'misc_discard': 'Discard',
      'misc_alarm': 'Alarm',
      'misc_cancel': 'Cancel',
      'misc_route': 'Route',
      'misc_subtitle': 'Hello there!',
      'settings_review_title': 'Review',
      'settings_review_subtitle': 'Gimme the Stars! ⭐',
      'misc_privacy': 'Privacy Policy',
      'misc_feedback_email_subject': '${StaticValues.appName} - feedback',
    },
  };

  String get settingsTitle =>
      _localizedValues[locale.languageCode]['settings_title'];

  String get markerSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_markers_title'];

  String get markerOptionBoth =>
      _localizedValues[locale.languageCode]['settings_markers_both'];

  String get markerOptionBike =>
      _localizedValues[locale.languageCode]['settings_markers_bike'];

  String get markerOptionBus =>
      _localizedValues[locale.languageCode]['settings_markers_bus'];

  String get themeOptionLight =>
      _localizedValues[locale.languageCode]['settings_themes_light'];

  String get themeOptionDark =>
      _localizedValues[locale.languageCode]['settings_themes_dark'];

  String get themeOptionBlack =>
      _localizedValues[locale.languageCode]['settings_themes_black'];

  String get locationSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_location_title'];

  String get locationOptionCurrent =>
      _localizedValues[locale.languageCode]['settings_location_current'];

  String get locationOptionTurku =>
      _localizedValues[locale.languageCode]['settings_markers_turku'];

  String get themeSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_theme_title'];

  String get notificationSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_notifications_title'];

  String get notificationSettingsSubtitle =>
      _localizedValues[locale.languageCode]['settings_notifications_subtitle'];

  String get languageSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_language_title'];

  String get languageOptionEn =>
      _localizedValues[locale.languageCode]['settings_language_en'];

  String get languageOptionFi =>
      _localizedValues[locale.languageCode]['settings_language_fi'];

  String get githubSettingsSubtitle =>
      _localizedValues[locale.languageCode]['settings_github_subtitle'];

  String get licensesSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_licenses_title'];

  String get aboutSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_about_title'];

  String get aboutSettingsSubtitle =>
      _localizedValues[locale.languageCode]['settings_about_subtitle'];

  String get shareSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_share_title'];

  String get shareSettingsSubtitle =>
      _localizedValues[locale.languageCode]['settings_share_subtitle'];

  String get reviewSettingsTitle =>
      _localizedValues[locale.languageCode]['settings_review_title'];

  String get reviewSettingsSubtitle =>
      _localizedValues[locale.languageCode]['settings_review_subtitle'];

  String get scheduleSheetNoBusesTitle => _localizedValues[locale.languageCode]
      ['sheets_schedulesheet_no_buses_title'];

  String get scheduleSheetNoBusesBody => _localizedValues[locale.languageCode]
      ['sheets_schedulesheet_no_buses_body'];

  String get bikeSheetBikesTitle =>
      _localizedValues[locale.languageCode]['sheets_bikesheet_bikes_title'];

  String get bikeSheetNoBikesTitle =>
      _localizedValues[locale.languageCode]['sheets_bikesheet_no_bikes_title'];

  String get bikeSheetNoBikesBodyFirstPart =>
      _localizedValues[locale.languageCode]
          ['sheets_bikesheet_no_bikes_bodyPart1'];

  String get bikeSheetNoBikesBodySecondPart =>
      _localizedValues[locale.languageCode]
          ['sheets_bikesheet_no_bikes_bodyPart2'];

  String get favoriteSheetTitle =>
      _localizedValues[locale.languageCode]['sheets_favoritesheet_title'];

  String get noFavoritesTitle => _localizedValues[locale.languageCode]
      ['sheets_favoritesheet_no_favorites_title'];

  String get noFavoritesSubtitle => _localizedValues[locale.languageCode]
      ['sheets_favoritesheet_no_favorites_subtitle'];

  String get favoriteEditTitle =>
      _localizedValues[locale.languageCode]['dialogs_edit_favorite_title'];

  String get favoriteEditFormTitle =>
      _localizedValues[locale.languageCode]['dialogs_edit_favorite_form_title'];

  String get favoriteEditFormHint =>
      _localizedValues[locale.languageCode]['dialogs_edit_favorite_form_hint'];

  String get favoriteEditFromWarning => _localizedValues[locale.languageCode]
      ['dialogs_edit_favorite_form_warning'];

  String get connectionDialogWarning =>
      _localizedValues[locale.languageCode]['dialogs_connection_warning'];

  String get locationDialogWarning =>
      _localizedValues[locale.languageCode]['dialogs_location_warning'];

  String get locationDialogWarningButton =>
      _localizedValues[locale.languageCode]['dialogs_location_warning_button'];

  String get miscTime => _localizedValues[locale.languageCode]['misc_time'];

  String get miscStopNo => _localizedValues[locale.languageCode]['misc_stopNo'];

  String get miscVersion =>
      _localizedValues[locale.languageCode]['misc_version'];

  String get miscScheduled =>
      _localizedValues[locale.languageCode]['misc_scheduled'];

  String get miscSchedulesUpdated =>
      _localizedValues[locale.languageCode]['misc_schedules_updated'];

  String get miscBusLocationUpdated =>
      _localizedValues[locale.languageCode]['misc_bus_location_updated'];

  String get miscBusNotificationInfo =>
      _localizedValues[locale.languageCode]['misc_bus_notification_arrival'];

  String get miscSearch => _localizedValues[locale.languageCode]['misc_search'];

  String get miscRefresh =>
      _localizedValues[locale.languageCode]['misc_refresh'];

  String get miscQuit => _localizedValues[locale.languageCode]['misc_quit'];

  String get miscApply => _localizedValues[locale.languageCode]['misc_apply'];

  String get miscDiscard =>
      _localizedValues[locale.languageCode]['misc_discard'];

  String get miscAlarm => _localizedValues[locale.languageCode]['misc_alarm'];

  String get miscCancel => _localizedValues[locale.languageCode]['misc_cancel'];

  String get miscRoute => _localizedValues[locale.languageCode]['misc_route'];

  String get aboutContactTitle =>
      _localizedValues[locale.languageCode]['about_contact_title'];

  String get aboutContactSubtitle =>
      _localizedValues[locale.languageCode]['about_contact_subtitle'];

  String get miscPrivacy =>
      _localizedValues[locale.languageCode]['misc_privacy'];

  String get miscEmailSubject =>
      _localizedValues[locale.languageCode]['misc_feedback_email_subject'];
}

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fi'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) =>
      SynchronousFuture<Localization>(Localization(locale));

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}
