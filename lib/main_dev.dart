
import "config.dart";
import "main.dart";
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


void main() {
  var configuredApp = new AppConfig(
    apiBaseUrl: 'http://192.168.1.16/app',
    child: new App(),
    stripePublishableKey: 'pk_test_VHG8gc7nhstCyG2NFIfvQhUg00kckE4Omt',
    stripeMerchantId: 'merchant.com.jovi',
    stripeAndroidPayMode: 'test',
  );

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(configuredApp);
}