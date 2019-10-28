import 'package:flutter/material.dart';
import "package:bevvymobile/dataStore.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:async';

typedef void OnClearBasket();

//Displayed in the main list views
class NewOrder extends StatefulWidget
{
  const NewOrder({ Key key, this.dataStore, this.isNative, this.onClearBasket}) : super(key: key);

  final DataStore dataStore;
  final bool isNative;
  final OnClearBasket onClearBasket;

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder>
{
  StreamSubscription<DocumentSnapshot> subscription;
  String orderState = 'edited_order';
  bool subscriptionCancelled = false;

  @override
  void initState() {
    postOrderHooks();
    super.initState();
  }

  void postOrderHooks()
  {
    subscription = widget.dataStore.orderStream.listen((DocumentSnapshot snap) async {
      if (snap.data['status'] == 'edited_order') {
        // Payment status hasn't changed
        return;
      } else if (snap.data['status'] == 'dispatch_queue') {
        // Yay! Payment has gone through
        subscription.cancel();
        subscriptionCancelled = true;
        setState(() {
          orderState = 'dispatch_queue';
        });
        if (widget.isNative) {
          StripePayment.completeNativePayRequest();
        }
        Future.delayed(Duration(seconds: 2)).then((x) {
          Navigator.pushNamed(context, '/order', arguments: widget.dataStore.order.documentID);
        });

      } else {
        // Error
        // TODO: error handle
        setState(() {
          orderState = 'error';
        });
        subscription.cancel();
        subscriptionCancelled = true;
        if (widget.isNative) {
          StripePayment.cancelNativePayRequest();
        }
      }
    });
    Future.delayed(Duration(seconds: 10)).then((x) {
      if (!subscriptionCancelled) {
        setState(() {
          orderState = 'timeout';
        });
        subscription?.cancel()?.then((FutureOr f) => subscriptionCancelled = true);
        Future.delayed(Duration(seconds: 2)).then((x) {
          widget.onClearBasket();
          Navigator.pushNamed(context, '/home');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String message;
    if(orderState == "edited_order") message = "Waiting For Server...";
    else if(orderState == "dispatch_queue") message = "Order Confirmed!";
    else if(orderState == "error") message = "An Unkown Error occured.";
    else if(orderState == "timeout") message = "The connection timed out.";
    
    return Scaffold
    (
      appBar: AppBar(title: Text("Order: " + widget.dataStore.order.documentID),),
      body: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>
        [
          CircularProgressIndicator(),
          Padding
          (
            padding: EdgeInsets.all(50),
            child: Center(child: Text(message))
          ),
        ],
      )
    );
  }
}