import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bevvymobile/reauthenticate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stripe_payment/stripe_payment.dart';

class PaymentMethods extends StatefulWidget
{
  const PaymentMethods({ Key key, this.user, this.paymentMethods }) : super(key: key);

  final FirebaseUser user;
  final List<PaymentMethod> paymentMethods;

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods>
{
  Future<bool> supportsNative;

  initState() {
    supportsNative = StripePayment.canMakeNativePayPayments([]);
    super.initState();
  }

  @override 
  Widget build(BuildContext context)
  {
    return FutureBuilder(
      future: supportsNative,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot)
      {
        if(snapshot.hasData)
        {
          return Scaffold
          (
            appBar: AppBar
            (
              title: Center(child: Text("Payment Methods")),
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
              children: getColumnContent(context, snapshot)
            )
          );
        }
        else
        {
          return Container();
        }
      }
    );
  }

  List<Widget> getColumnContent(BuildContext context, AsyncSnapshot<bool> snapshot)
  {
    List<Widget> content = 
    [
      snapshot.data ? (Platform.isIOS ?
        RaisedButton
        (
          child: Container
          (
            width: double.infinity,
            child: Text("Apple pay"),
          ),
          onPressed: () {}
        )
      :
      RaisedButton
      (
        child: Container
        (
          width: double.infinity,
          child: Text("Apple pay"),
        ),
        onPressed: () {}
      )) : Container(),
    ]

    content.addAll(
      widget.paymentMethods.map((PaymentMethod method)
      {
        return FlatButton
        (
          child: Text(method == null ? "" : (method.card == null ? "" : method.card.last4 ?? "")),
          onPressed: (){},
        );
      })
    );

    content.add
    (
      FlatButton
      (
        child: Container
        (
          width: double.infinity,
          child: Text("Add a new Card"),
        ),
        onPressed: () {
          StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod) {
            Firestore.instance.collection('users').document(widget.user.uid).collection('payment_methods').document(paymentMethod.id).setData({
              'json': paymentMethod.toJson(),
            });
          });
        }
      )
    );

    return content;
  }
}
