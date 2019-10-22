import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyBbaW0SyM9LcEiDPGNeMxmtQB0vK8Hhh-o");

    let controller = window?.rootViewController as! FlutterViewController
    let applePayButtonFactory = ApplePayButtonFactory(controller);
    registrar(forPlugin: "ApplePayButton").register(applePayButtonFactory, withId: "ApplePayButton")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
