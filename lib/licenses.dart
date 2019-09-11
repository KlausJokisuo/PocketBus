import 'package:flutter/foundation.dart';

final List<LicenseEntry> _licenseList = [
  const LicenseEntryWithLineBreaks(<String>['icons'], '   Icons8 icons8.com'),
  const LicenseEntryWithLineBreaks(
      <String>['föli'],
      '   Turku Region Public Transport Traffic and Schedule Data.'
      ' The administrator of the material is the Public Transport Office of the City of Turku.'
      ' The material has been downloaded from http://data.foli.fi/ under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.'),
  const LicenseEntryWithLineBreaks(
      <String>['flare hearth'],
      '  flare hearth-simple'
      ' The material has been downloaded from https://www.2dimensions.com/a/pollux/files/flare/heart-simple/ under the Creative Commons Attribution 4.0 International (CC BY 4.0) license. File has been modified by Klaus Jokinen'),
];

void generateLicenses() {
  for (final licence in _licenseList) {
    LicenseRegistry.addLicense(
        () => Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
              licence,
            ]));
  }
}
