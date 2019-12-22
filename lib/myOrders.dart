import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/orderWidget.dart';
import 'package:flutter/material.dart';


class MyOrders extends StatefulWidget
{
  const MyOrders({Key key, this.orders, this.statusNames, this.onOrderAgain}) : super(key: key);

  final List<Order> orders;
  final Map<String, String> statusNames;
  final OnOrderAgain onOrderAgain;

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders>
{
  bool isInProgressOrders = true; //If there are no pending/in progress orders, only show older orders.
  bool hasToggledOldOrders = false; //Otherwise, toggle to/from pending and fullfilled orders
  List<Order> currentlyDisplayedItems;
  @override
  void initState() {
    currentlyDisplayedItems = widget.orders.where((Order order) => ["dispatch_queue", "delayed_queue", "out_for_delivery"].contains(order.status)).toList();
    if(currentlyDisplayedItems.length == 0)
    {
      currentlyDisplayedItems = widget.orders.where((Order order) => !["new_order", "synced_editing_order", "stripe_paymentintent_payment_failed"].contains(order.status)).toList();
      isInProgressOrders = false;
    }
    currentlyDisplayedItems.sort((Order a, Order b) => b.date.compareTo(a.date));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders", style: TextStyle(fontFamily: "opificio")),
      ),
      body: Column(
        children:
        [
          Expanded(
            child: currentlyDisplayedItems.length == 0 ?
            Padding(
              padding: EdgeInsets.all(20),
              child: Text("No Orders Found.", style: TextStyle(fontSize: 28),)
            )
            :ListView(
              children: currentlyDisplayedItems.map<Widget>((Order order) => OrderWidget(order: order, statusNames: widget.statusNames, onOrderAgain: widget.onOrderAgain,)).toList()
            )
          ),
          isInProgressOrders ? Card(
            child: FlatButton(
              onPressed: (){
                if(hasToggledOldOrders)
                {
                  setState(() {
                    hasToggledOldOrders = false;
                    currentlyDisplayedItems = widget.orders.where((Order order) => ["dispatch_queue", "delayed_queue", "out_for_delivery"].contains(order.status)).toList();
                    currentlyDisplayedItems.sort((Order a, Order b) => b.date.compareTo(a.date));
                  });
                }
                else
                {
                  setState(() {
                    hasToggledOldOrders = true;
                    currentlyDisplayedItems = widget.orders.where((Order order) => !["dispatch_queue", "delayed_queue", "out_for_delivery", "new_order", "synced_editing_order", "stripe_paymentintent_payment_failed"].contains(order.status)).toList();
                    currentlyDisplayedItems.sort((Order a, Order b) => b.date.compareTo(a.date));
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                child: Center(child: Text(hasToggledOldOrders ? "Back to Current Orders" : "See Fufilled Orders")),
              ),
            ),
          ) : Container()
        ]
      ),
    );
  }
}