import Foundation
import UIKit
import PassKit

public class ApplePayButton: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    
    init(_ frame: CGRect, viewId: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewId
    }
    
    public func view() -> UIView {
        return PKPaymentButton.init(paymentButtonType: PKPaymentButtonType.buy,
                                    paymentButtonStyle: PKPaymentButtonStyle.white)
    }
}
