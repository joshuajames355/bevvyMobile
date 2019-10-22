import Foundation
import UIKit

public class MyWebview: NSObject, FlutterPlatformView, WKScriptMessageHandler, WKNavigationDelegate {
    let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {

        let button = PKPaymentButton(type: PKPaymentButtonType.Buy, style: PKPaymentButtonStyle.White)

        super.init()
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
        })
    }
    
    public func view() -> UIView {
        return self.button
    }
