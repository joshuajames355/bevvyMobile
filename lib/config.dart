import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  AppConfig({
    @required this.apiBaseUrl,
    @required Widget child,
    @required this.stripePublishableKey,
    @required this.stripeMerchantId,
    @required this.stripeAndroidPayMode,
  }) : super(child: child);

  final String apiBaseUrl;
  final String stripePublishableKey;
  final String stripeMerchantId;
  final String stripeAndroidPayMode;

  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}