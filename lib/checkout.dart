import 'dart:io';

import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stripe_payment/stripe_payment.dart';

typedef void OnChangeSelectedMethod(PaymentMethod selectedMethod);

class Checkout extends StatefulWidget
{
  const Checkout({ Key key, this.checkoutData, this.location, this.paymentMethod}) : super(key: key);

  final Map<Product, int> checkoutData; //List of products/quantities
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
                Text("£" + (getTotal(widget.checkoutData) + (getTotal(widget.checkoutData) > 25 ? 0 : 3.50)).toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor)),
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
                  child: Center(child: Text("Change Payment Method")),
                ),
                onPressed:  ()
                {
                  Navigator.pushNamed(context, '/paymentMethods');
                },  
            ),            
            ),
          ),
          isKeyboardHidden ? Container() : 
          (widget.paymentMethod != null && (widget.paymentMethod.type == "google" || widget.paymentMethod.type == "apple")) ? nativePayButton(context)
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
                  Text("Buy with ")
                ]..addAll(getPaymentMethodIndicator())                
              ),
            ),
            onPressed: widget.paymentMethod == null ? null : ()
            {
              //Todo: place an order
              Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
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
    else if(Platform.isIOS)
    {
      return InkWell
      (
        onTap: ()
        {
          //TODO: apple pay
          Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
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
          padding: EdgeInsets.only(left: 20, right: 10),
        ),
        Text(brand + " Ending in " + widget.paymentMethod.card.last4)
      ];
    }
    //google pay or apple pay
    else 
    {
      return [Text("Payment Method Invalid")];
    }
  }
}