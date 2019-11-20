import 'dart:math';

import 'package:bevvymobile/newOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:bevvymobile/dataStore.dart';
import 'package:bevvymobile/utils.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Checkout extends StatefulWidget
{
  const Checkout({ Key key, this.dataStore, this.paymentMethod, this.deliveryCenterLat, this.deliveryCenterLon, this.deliveryRadius, this.statusNames}) : super(key: key);

  final DataStore dataStore;
  final PaymentMethod paymentMethod;

  final double deliveryRadius;
  final double deliveryCenterLat;
  final double deliveryCenterLon;
  final Map<String, String> statusNames;

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
  int orderUpdateEventID = -1;

  String orderStatus = "pending";

  Set<Circle> circles;

  @override
  void initState() {
    getLocation();
    circles = Set.from([Circle(
      circleId: CircleId("delivery"),
      center: LatLng(widget.deliveryCenterLat, widget.deliveryCenterLon),
      radius: widget.deliveryRadius * 1000,
    )]);
    cameraPosition = CameraPosition(target: lastLocationFix == null ? LatLng(54.7753, -1.5849) : LatLng(lastLocationFix.latitude, lastLocationFix.longitude), zoom: 16);
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return orderStatus == "pending" ? Scaffold
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
                  circles: circles,
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
                Align
                (
                  alignment: Alignment.center,
                  child: Transform.translate
                  (
                    offset: Offset(0, -25),
                    child: Icon(IconData(57544, fontFamily: 'MaterialIcons',), color: Theme.of(context).accentColor, size: 50,),
                  )
                ),     
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
              double distance = distBetweenPoints(widget.deliveryCenterLat, widget.deliveryCenterLon, cameraPosition.target.latitude, cameraPosition.target.longitude);
              if(distance < widget.deliveryRadius * 1000)
              {
                showModalBottomSheet
                (
                  isScrollControlled: true,
                  context: context, builder: (BuildContext context2) => bottomModal(context2)
                );
              }
              else
              {
                showPlatformDialog(androidBarrierDismissible: true,context: context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("Error"), content: Text("We do not deliver to that location.")));
              }
            },
          )
        ]
      ),
      floatingActionButton: PlatformWidget
      (
        android: (_) => Padding
        (
          padding: EdgeInsets.only(bottom: 50),
          child: FloatingActionButton
          (
            child: Icon(IconData(58716, fontFamily: 'MaterialIcons')),
            onPressed: getLocation,
          ),
        )
      )
    ) : NewOrder(orderStatus: orderStatus, statusNames: widget.statusNames, orderID: widget.dataStore.order.documentID,);
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
    return SafeArea(
      child: Column
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
              showPlatformDialog(context: context,
                          builder: (context) {
                            return PlatformAlertDialog(
                              content: Text('Confirm payment of ' + widget.dataStore.orderAmountStringWithCurrency),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Close'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                FlatButton(
                                  child: Text('Pay'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    runExistingCardPayment();
                                  },
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
        onTap: doNativePayment,
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
        onTap: doNativePayment,
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

  void doNativePayment() async
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
    if(widget.dataStore.order.data["status"] == "new_order")
    {
      showPlatformDialog(androidBarrierDismissible: true,context: context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("Error"), content: Text("A server Error has occured.\nPlease Try Again Later.")));
      return;
    }

    setState(() {
     orderStatus = "edited_order" ;
    });

    
    StripePayment.confirmPaymentIntent(
      PaymentIntent(clientSecret: widget.dataStore.order['stripePaymentIntentClientSecret'],
                    paymentMethodId: paymentMethodID)
    ).catchError((error){
      print(error);

      setState(() {
        orderStatus = "error";
      });

      StripePayment.cancelNativePayRequest();

      if(error is PlatformException)
      {
        //3D secured cancelled - PlatformException(failed, failed, null)
        if (error.code != 'authenticationFailed') {
          if(error.code == "api") // stripe failure
          {
            if(error.message == "Your card was declined.")
            setState(() {
              orderStatus = "error_card_declined";
            });
          }
          print(error.message);
          // TODO
          // Payment(Intent) will have failed, so have to create a new order(?), definitely a new PaymentIntent.
        }
      }
    });

    orderUpdateEventID = widget.dataStore.subscribeToOrderUpdate((DocumentSnapshot snap) async {
      if (snap.data['status'] == 'edited_order') {
        // Payment status hasn't changed
        return;
      } else if (snap.data['status'] == 'dispatch_queue') {
        // Yay! Payment has gone through

        setState(() {
          orderStatus = 'dispatch_queue';
        });

        if (isNative) {
          StripePayment.completeNativePayRequest();
        }
        Future.delayed(Duration(seconds: 1)).then((x) {
          widget.dataStore.reset();
          Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
          Navigator.pushNamed(context, '/order', arguments: snap.documentID);
        });

      } else {

        // Error
        // TODO: error handle
        // Again, need to reset basket / payment intent if we want to allow the user to retry.
        if(!orderStatus.startsWith("error")){
          setState(() {
            orderStatus = 'error';
          });
        }

        if (isNative) {
          StripePayment.cancelNativePayRequest();
        }
      }
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteToDriver.dispose();
    if(orderUpdateEventID != -1) widget.dataStore.unsubscribeFromOrderUpdates(orderUpdateEventID);
    super.dispose();
  }
}