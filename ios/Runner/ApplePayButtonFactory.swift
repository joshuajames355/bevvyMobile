import Foundation

public class ApplePayButtonFactory : NSObject, FlutterPlatformViewFactory {
   let controller: FlutterViewController
    
    init(controller: FlutterViewController) {
        self.controller = controller
    }
    
    public func create(
    ) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(
            name: "ApplePayButton" + String(viewId),
            binaryMessenger: controller
        )
        return MyWebview(channel: channel)
    }
}
