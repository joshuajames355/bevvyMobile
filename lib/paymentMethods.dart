import 'package:flutter/material.dart';
import 'package:bevvymobile/reauthenticate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentMethods extends StatefulWidget
{
  const PaymentMethods({ Key key, this.user}) : super(key: key);

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods>
{
  Future<bool> supportsNative;

  initState()
  {
    supportsNative = StripePayment.canMakeNativePayments();
    super.init
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
                snapshot.data ? (Theme.of(context).targetPlatform == "ios" ?
                  RaisedButton
                  (
                    child: Container
                    (
                      width: double.infinity,
                      child: Text("Apple pay"),
                    ),
                    onpressed: () {}
                  )
                :
                RaisedButton
                (
                  child: Container
                  (
                    width: double.infinity,
                    child: Text("Apple pay"),
                  ),
                  onpressed: () {}
                )) : Container(),
                FlatButton
                (
                  child: Container
                  (
                    width: double.infinity,
                    child: Text("Add new Card"),
                    onpressed: ()
                    {
                      StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod)
                      {  
                        Firestore.instance.collection('users').document(widget.user.uid).collection('payment_methods').document(paymentMethod.id).setData({
                          'json': paymentMethod.toJson(),
                          }
                        })
                      });
                    }
                  )
                )
              ]
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


}
