import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:bevvymobile/dataStore.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';

class Checkout extends StatefulWidget
{
  const Checkout({ Key key, this.dataStore, this.paymentMethod}) : super(key: key);

  final DataStore dataStore;
  final PaymentMethod paymentMethod;

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout>
{
  GoogleMapController _googleController;
  FocusNode _noteToDriver = FocusNode();

  //GPS location
  Location location = Location();
  LocationData lastLocationFix;

  CameraPosition cameraPosition; 

  @override
  void initState() {
    getLocation();
    cameraPosition = CameraPosition(target: lastLocationFix == null ? LatLng(54.7753, -1.5849) : LatLng(lastLocationFix.latitude, lastLocationFix.longitude), zoom: 16);
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text("Select Location"),
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
          Expanded
          (
            child: Stack
            (
              children: 
              [
                GoogleMap
                (
                  initialCameraPosition: cameraPosition,
                  onCameraMove: (CameraPosition position)
                  {
                    cameraPosition = position;
                  },
                  onMapCreated: (GoogleMapController controller)
                  {
                    _googleController = controller;
                    if(lastLocationFix != null)
                    {
                      _googleController.animateCamera(CameraUpdate.newLatLng(LatLng(lastLocationFix.latitude, lastLocationFix.longitude)));
                    }
                  },
                ),
                Positioned.fill
                (
                  child: Align
                  (
                    alignment: Alignment.center,
                    child: Transform.translate
                    (
                      offset: Offset(0, -25),
                      child: Icon(IconData(57544, fontFamily: 'MaterialIcons',), color: Theme.of(context).accentColor, size: 50,),
                    )
                  ),
                )          
              ]
            ),
          ),
          RaisedButton
          (
            child:  Container
            (
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Center
              (
                child: Text("Confirm Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ),
              width: double.infinity,
            ),
            onPressed: ()
            {
              //Navigator.pushNamed(context, "/checkout", arguments: cameraPosition.target);
              showModalBottomSheet
              (
                isScrollControlled: true,
                context: context, builder: (BuildContext context2) => bottomModal(context2)
              );
            },
          )
        ]
      ),
      floatingActionButton: Padding
      (
        padding: EdgeInsets.only(bottom: 50),
        child: FloatingActionButton
        (
          child: Icon(IconData(58716, fontFamily: 'MaterialIcons')),
          onPressed: getLocation,
        ),
      )
    );
  }

  getLocation()
  {
    location.getLocation().then((LocationData data)
    {
      if(_googleController != null)
      {
        _googleController.animateCamera(CameraUpdate.newLatLng(LatLng(data.latitude, data.longitude)));
      }
      lastLocationFix = data;
    }).catchError((e)
    {
      print(e);

    });
  }

  Widget bottomModal(BuildContext context)
  {
    return Column
    (
      mainAxisSize: MainAxisSize.min,
      children: 
      [ 
        Padding
        (
          padding: EdgeInsets.only(left: 15, right: 15, top: 20),
          child: Row
          (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: 
            [
              Text("Total", style: TextStyle(fontSize: 16)),
              Text(widget.dataStore.orderAmountStringWithCurrency, style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor)),
            ]
          ),
        ),
        Padding
        (
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: TextField
          (
            autofocus: true,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'House Number/Name',
            ),
            onSubmitted: (_)
            {
              _noteToDriver.requestFocus();
            },
          ),
        ),
        Padding
        (
          padding: EdgeInsets.only(bottom: max(10, MediaQuery.of(context).viewInsets.bottom-80), left: 15, right: 15),
          child: TextField
          (
            focusNode: _noteToDriver,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Note to Driver',
            ),
            onSubmitted: (_)
            {
              FocusNode().requestFocus();
            },
          ),
        ),
        Card
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
              Navigator.pushNamed(context, '/paymentMethods');
            },  
          ),            
        ),
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
        // Navigator.pushNamed(context, '/order');
        Navigator.pushNamed(context, '/home');
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

  @override
  void dispose() {
    _noteToDriver.dispose();
    super.dispose();
  }
}