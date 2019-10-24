import 'dart:async';
import 'dart:io';

import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/dataStore.dart';
import 'package:bevvymobile/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter/services.dart';
import 'package:stripe_payment/stripe_payment.dart' as prefix0;


typedef void OnChangeSelectedMethod(PaymentMethod selectedMethod);

class Checkout extends StatefulWidget
{
  const Checkout({ Key key, this.user, this.dataStore, this.location, this.paymentMethod}) : super(key: key);

  final FirebaseUser user;
  final DataStore dataStore;
  final PaymentMethod paymentMethod;
  final LatLng location;

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> 
{

  @override
  Widget build(BuildContext context) {
    bool isKeyboardHidden = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text("Checkout"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ), 
      body: Column
      (
        children: 
        [ 
          Padding
          (
            padding: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 10),
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: 
              [
                Text("Total", style: TextStyle(fontSize: 16)),
                Text("£" + (getTotal(widget.dataStore.checkoutData) + (getTotal(widget.dataStore.checkoutData) > 25 ? 0 : 3.50)).toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor)),
              ]
            ),
          ),
          Padding
          (
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField
            (
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'House Number/Name',
              ),
            ),
          ),
          Padding
          (
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField
            (
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Note to Driver',
              ),
            ),
          ),
          isKeyboardHidden ? Container() : Expanded(child: Container(),),
          isKeyboardHidden ? Container() : Padding
          (
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Card
            (
              child: FlatButton
              (
                child: Container
                (
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  child: Center(child: Text((widget.dataStore.orderRef == null ? "Create Firestore Order" : "Update Firestore Order"))),
                ),
                onPressed:  () async
                {
                  try {
                    if (widget.dataStore.orderRef == null) {
                      widget.dataStore.createFirestoreOrder(widget.user.uid);
                    } else {
                      widget.dataStore.updateFirestoreOrder();
                    }
                  } catch (error) {
                    print(error);
                  }
                },
            ),            
            ),
          ),
          isKeyboardHidden ? Container() : Padding
          (
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Card
            (
              child: FlatButton
              (
                child: Container
                (
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  child: Center(child: Text("Change Payment Method")),
                ),
                onPressed:  ()
                {
                  // widget.dataStore.reset();
                  // widget.dataStore.setOrderRef(Firestore.instance.collection('orders').document('NPQJBT2VMtzbMMTMLe1L'));
                  Navigator.pushNamed(context, '/paymentMethods');
                },  
            ),            
            ),
          ),
          isKeyboardHidden ? Container() : 
          (widget.paymentMethod != null && (widget.paymentMethod.type == "googlepay" || widget.paymentMethod.type == "applepay")) ? nativePayButton(context)
          : RaisedButton
          (
            child: Container
            (
              padding: EdgeInsets.all(15),
              width: double.infinity,
              child:  Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  Text("Buy with")
                ]..addAll(getPaymentMethodIndicator())                
              ),
            ),
            onPressed: widget.paymentMethod == null ? null : ()
            {
              //Todo: place an order
              // Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
              showDialog(context: context,
                         builder: (context) {
                           return AlertDialog(
                             content: Text('Confirm payment of ' + widget.dataStore.orderAmountStringWithCurrency),
                             actions: <Widget>[
                               FlatButton(
                                 child: Text('Close'),
                                 onPressed: () => Navigator.pop(context),
                               ),
                               FlatButton(
                                 child: Text('Pay'),
                                 onPressed: () => runExistingCardPayment(),
                               )
                             ]);
                         });
            },
          ),
        ]
      ),
    );
  }

  Widget nativePayButton(BuildContext context)
  {
    if(Platform.isAndroid)
    {
      return InkWell
      (
        onTap: ()
        {
          //TODO: google pay
          Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
        },
        child: Container
        (
          height: 50,
          child: AndroidView
          (
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            viewType: 'GooglePayButton',
          )   
        )
      );
    }
    else
    {
      return InkWell
      (
        onTap: () async
        {
          try {
            Token nativePayToken = await StripePayment.paymentRequestWithNativePay(
              androidPayOptions: AndroidPayPaymentRequest(
                total_price: widget.dataStore.orderAmountString,
                currency_code: "GBP",
              ),
              applePayOptions: ApplePayPaymentOptions(
                countryCode: 'GB',
                currencyCode: 'GBP',
                items: widget.dataStore.basketAsApplePayItems
              ));

              // Send token to backend
              PaymentMethod nativePayTempPaymentMethod = await StripePayment.createPaymentMethod(PaymentMethodRequest(card: CreditCard(token: nativePayToken.tokenId)));
              runAllCardPayment(nativePayTempPaymentMethod.id, true);
          } on PlatformException catch(exception) {
            // 'cancelled' operation indicates user has dismissed modal window (iOS only)
            if (exception.code != 'cancelled') {
              rethrow;
            }
          } catch (error) {
            print(error);
          }
        },
        child: Container
        (
          height: 50,
          child: UiKitView
          (
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            viewType: 'ApplePayButton',
          )   
        )
      );
    }
  }

  List<Widget> getPaymentMethodIndicator()
  {
    if(widget.paymentMethod == null)
    {
      return [];
    }
    else if(widget.paymentMethod.type == "card")
    {
      if(widget.paymentMethod.card == null) return [Text("Invalid Card")];

      //capitalize brand
      var brand = widget.paymentMethod.card.brand;
      brand = brand[0].toUpperCase() + brand.substring(1);

      return 
      [
        Padding
        (
          child: Icon(IconData(59553, fontFamily: 'MaterialIcons')),
          padding: EdgeInsets.only(left: 6, right: 5),
        ),
        Text(brand + " ending in " + widget.paymentMethod.card.last4)
      ];
    }
    //google pay or apple pay
    else 
    {
      return [Text("Payment Method Invalid")];
    }
  }

  void runExistingCardPayment() async {
    runAllCardPayment(widget.paymentMethod.id, false);
  }

  void runAllCardPayment(String paymentMethodID, bool isNative) async {
    try {
      StripePayment.confirmPaymentIntent(
        PaymentIntent(clientSecret: widget.dataStore.order['stripePaymentIntentClientSecret'],
                      paymentMethodId: paymentMethodID)
      );
    } on PlatformException catch(exception) {
      // Cancel just native pay
      StripePayment.cancelNativePayRequest();

      // Present error for all cards
      if (exception.code != 'authenticationFailed') {
        print(exception.message);
        // TODO
        // Payment(Intent) will have failed, so have to create a new order(?), definitely a new PaymentIntent.
      } else {
        rethrow;
      }
    } catch (error) {
      print(error);
    }

    bool subscriptionCancelled = false;
    StreamSubscription<DocumentSnapshot> subscription;
    subscription = widget.dataStore.orderStream.listen((DocumentSnapshot snap) async {
      if (snap.data['status'] == 'edited_order') {
        // Payment status hasn't changed
        return;
      } else if (snap.data['status'] == 'dispatch_queue') {
        // Yay! Payment has gone through
        subscription.cancel();
        subscriptionCancelled = true;
        if (isNative) {
          StripePayment.completeNativePayRequest();
        }
        Navigator.pushNamed(context, '/order');
      } else {
        // Error
        // TODO: error handle
        subscription.cancel();
        subscriptionCancelled = true;
        if (isNative) {
          StripePayment.cancelNativePayRequest();
        }
      }
    });
    Future.delayed(Duration(seconds: 10)).then((x) {
      if (!subscriptionCancelled) {
        subscription?.cancel()?.then((FutureOr f) => subscriptionCancelled = true);
      }
    });

    // TODO
    // Move to order progress screen and show animation while waiting for WebHook to update and confirm progress
  }
}