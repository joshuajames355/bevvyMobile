import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override 
  Widget build(BuildContext context)
  {
    return  Scaffold
    (
      appBar: AppBar
      (
        title: Text("Payment Methods"),
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
        children: getColumnContent(context)
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
        child: Icon(IconData(59553, fontFamily: 'MaterialIcons'), size: 200,),
      )
    ];

    content.addAll(
      widget.paymentMethods.map((PaymentMethod method)
      {
        var brand = method.card.brand ?? "";
        brand = brand[0].toUpperCase() + brand.substring(1);
        return FlatButton
        (
          onPressed: ()
          {
            widget.onChangeSelectedMethod(method);
          },
          child: Card
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
                    child: Icon(IconData(59553, fontFamily: 'MaterialIcons')),
                    padding: EdgeInsets.all(12),
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

    content.addAll
    (
      [
        Divider(),
        FlatButton
        (
          child: Card
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
                    padding: EdgeInsets.all(12),
                  ),
                  Text("Add New Card..."),
                ]
              )
            ),
          ),
          onPressed: () {
            var temp = new CardFormPaymentRequest();
            StripePayment.paymentRequestWithCardForm(temp).then((PaymentMethod paymentMethod) {
              Firestore.instance.collection('users').document(widget.user.uid).collection('payment_methods').document(paymentMethod.id).setData({
                'json': paymentMethod.toJson(),
              });
            }).catchError((error)
            {
              print(error);
            });
          }
        )
      ]
    );

    return content;
  }
}
