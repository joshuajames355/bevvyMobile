import 'dart:io';

import 'package:bevvymobile/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stripe_payment/stripe_payment.dart';

typedef void OnChangeSelectedMethod(PaymentMethod selectedMethod);

class PaymentMethods extends StatefulWidget
{
  const PaymentMethods({ Key key, this.user, this.paymentMethods, this.selectedMethod, this.onChangeSelectedMethod }) : super(key: key);

  final FirebaseUser user;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod selectedMethod;
  final OnChangeSelectedMethod onChangeSelectedMethod;

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods>
{
  Future<bool> canMakeNativePay;

  @override
  void initState() {
    canMakeNativePay = StripePayment.canMakeNativePayPayments([]);
    super.initState();
  }

  @override 
  Widget build(BuildContext context)
  {
    return  Scaffold
    (
      resizeToAvoidBottomInset: false,
      appBar: AppBar
      (
        title: Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
          [
            Text("Payment Methods", style: TextStyle(fontFamily: "opificio")),
            (widget.selectedMethod == null || widget.selectedMethod.type != "card") ? Container() : IconButton
            (
              icon: Icon(const IconData(57693, fontFamily: 'MaterialIcons')),
              onPressed: ()
              {
                Firestore.instance.collection('users').document(widget.user.uid).collection('payment_methods').document(widget.selectedMethod.id).delete();
              },
            )
          ]
        ),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),        
      ),
      body: Column
      (
        children: [
          Expanded(
            child: ListView(
              children: getColumnContent(context)
            )
          ),
          Divider(),
          Card
          (
            child: FlatButton
            (
              child: Container
              (
                width: double.infinity,
                child: Row
                (
                  children:
                  [
                    Padding
                    (
                      child: Icon(IconData(57669, fontFamily: 'MaterialIcons')),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    Text("Add New Card..."),
                  ]
                )
              ),
              onPressed: () async {
                try {
                  PaymentMethod paymentMethod = await StripePayment.paymentRequestWithCardForm(
                    CardFormPaymentRequest(requiredBillingAddressFields: 'full',
                                          prefilledInformation: PrefilledInformation(billingAddress: BillingAddress(country: 'GB'))));
                  // Store in user's private Firestore collection, ready to be consumed by Function to attach to customer
                  Firestore.instance.collection('users').document(widget.user.uid).collection('payment_methods').document(paymentMethod.id).setData({
                    'asJSON': paymentMethod.toJson(),
                    'stripe_attachment': 'unattached',
                    'stripe_message': '',
                  });
                } on PlatformException catch(exception) {
                  // 'cancelled' operation indicates user has dismissed modal window (iOS only)
                  if (exception.code != 'cancelled') {
                    rethrow;
                  }
                }
              }
            )
          )
        ]
      )
    );
  }

  List<Widget> getColumnContent(BuildContext context)
  {
    List<Widget> content = 
    [
      Padding
      (
        padding: EdgeInsets.all(10),
        child: Icon(FontAwesomeIcons.creditCard, size: 125,),
      ),
      Divider(),
      FutureBuilder
      (
        future: canMakeNativePay,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot)
        {
          if(snapshot.hasData && snapshot.data)
          {
            if(Platform.isAndroid)
            {
              return androidPayButton(context);
            }
            else if (Platform.isIOS)
            {
              return applePayButton(context);
            }
            else
            {
              return Container(); 
            }
          }
          else
          {
            return Container();
          }
        },
      )      
    ];

    content.addAll(
      widget.paymentMethods.map((PaymentMethod method)
      {
        var brand = method.card.brand ?? "";
        brand = brand[0].toUpperCase() + brand.substring(1);
        return Card
        (
          child: FlatButton
          (
            onPressed: ()
            {
              widget.onChangeSelectedMethod(method);
            },
            child: Container
            (
              width: double.infinity,
              child: Row
              (
                children:
                [
                  Padding
                  (
                    child: getCardBrandIcon(brand),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  method.card == null ? Container() : Text(brand + " Ending in " + (method.card.last4 ?? "")),
                  Expanded
                  (
                    child: Container(),
                  ),
                  widget.selectedMethod.id == method.id ? Padding
                  (
                    child: Icon(const IconData(58826, fontFamily: 'MaterialIcons'), color: Theme.of(context).accentColor,),
                    padding: EdgeInsets.all(12),
                  ) : Container(),
                ]
              )
            ),
          )
        );
      })
    );
    
    return content;
  }

  Widget androidPayButton(BuildContext context)
  {
    return Card
    (
      child: FlatButton
      (
        onPressed: ()
        {
          widget.onChangeSelectedMethod(PaymentMethod(type: "googlepay"));
        },
        child: Container
        (
          width: double.infinity,
          child: Row
          (
            children:
            [
              Padding
              (
                child: Image
                (
                  height: 35,
                  width: 35,
                  image: AssetImage
                  (
                    'images/GooglePay_mark_800_gray.png',
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              ),
              Text("Google Pay"),
              Expanded
              (
                child: Container(),
              ),
              widget.selectedMethod != null && widget.selectedMethod.type == "googlepay" ? Padding
              (
                child: Icon(const IconData(58826, fontFamily: 'MaterialIcons'), color: Theme.of(context).accentColor,),
                padding: EdgeInsets.all(12),
              ) : Container(),
            ]
          )
        ),
      )
    );
  }

  Widget applePayButton(BuildContext context)
  {
    return Card
    (
      child: FlatButton
      (
        onPressed: ()
        {
          widget.onChangeSelectedMethod(PaymentMethod(type: "applepay"));
        },
        child: Container
        (
          width: double.infinity,
          child: Row
          (
            children:
            [
              Padding
              (
                child: Image
                (
                  height: 35,
                  width: 35,
                  image: AssetImage
                  (
                    'images/Apple_Pay_Mark_RGB_041619.png',
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              ),
              Text("Apple Pay"),
              Expanded
              (
                child: Container(),
              ),
              (widget.selectedMethod != null && widget.selectedMethod.type == "applepay") ? Padding
              (
                child: Icon(const IconData(58826, fontFamily: 'MaterialIcons'), color: Theme.of(context).accentColor,),
                padding: EdgeInsets.all(12),
              ) : Container()
            ]
          )
        ),
      )
    );
  }
}
