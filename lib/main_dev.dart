
import "config.dart";
import "main.dart";
import 'package:flutter/material.dart';

void main() {
  var configuredApp = new AppConfig(
    apiBaseUrl: 'http://192.168.1.16/app',
    child: new MyApp(),
  );

  runApp(configuredApp);
}