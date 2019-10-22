import "config.dart";
import "main.dart";
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


void main() {
  var configuredApp = new AppConfig(
    apiBaseUrl: '',
    child: new App(),
    stripePublishableKey: 'pk_live_gqGEMc8ERbGPQ2VRJGen2sF400ZoN72LDi',
    stripeMerchantId: 'merchant.com.jovi',
    stripeAndroidPayMode: 'production',
  );

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(configuredApp);
}