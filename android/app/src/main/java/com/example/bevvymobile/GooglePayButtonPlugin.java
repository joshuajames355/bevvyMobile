package com.example.bevvymobile;

import io.flutter.plugin.common.PluginRegistry.Registrar;

public class GooglePayButtonPlugin {
  public static void registerWith(Registrar registrar) {
    registrar
            .platformViewRegistry()
            .registerViewFactory(
                    "GooglePayButton", new GooglePayButtonFactory(registrar.messenger()));
  }
}