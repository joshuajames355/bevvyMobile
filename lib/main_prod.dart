import "config.dart";
import "main.dart";
import 'package:flutter/material.dart';

void main() {
  var configuredApp = new AppConfig(
    apiBaseUrl: '',
    child: new App(),
  );

  runApp(configuredApp);
}