import "config.dart";
import "main.dart";
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


void main() {
  var configuredApp = new AppConfig(
    apiBaseUrl: '',
    child: new App(),
  );

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(configuredApp);
}