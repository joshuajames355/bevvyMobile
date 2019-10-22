import Foundation

public class ApplePayButtonFactory : NSObject, FlutterPlatformViewFactory {
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return ApplePayButton(frame, viewId: viewId, args: args)
    }
}
