import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';

import '../bin/hds_desktop.dart' as app;

void main() {
  final pubspec = Pubspec.parse(File('pubspec.yaml').readAsStringSync());
  if (pubspec.version != app.version) {
    throw 'Version mismatch: pubspec.yaml has ${pubspec.version}, but bin/hds_desktop.dart has ${app.version}';
  } else {
    print('Version check passed');
  }
}
