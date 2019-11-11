import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/utils.dart';
import 'package:flutter/material.dart';

typedef void OnOrderAgain(Order order);

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
      currentlyDisplayedItems = widget.orders;
      isInProgressOrders = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
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
                  });
                }
                else
                {
                  setState(() {
                    hasToggledOldOrders = true;
                    currentlyDisplayedItems = widget.orders.where((Order order) => !["dispatch_queue", "delayed_queue", "out_for_delivery", "new_order", "synced_editing_order", "stripe_paymentintent_payment_failed"].contains(order.status)).toList();
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

class OrderWidget extends StatelessWidget
{
    const OrderWidget({Key key, this.order, this.statusNames, this.onOrderAgain}) : super(key: key);

    final Order order;
    final Map<String, String> statusNames;
    final OnOrderAgain onOrderAgain;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FlatButton(
        onPressed: () => Navigator.pushNamed(context, "/order", arguments: order.orderID),
        child: Container(
          height: 175,
          width: double.infinity,
          margin: EdgeInsets.all(7),
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: Text(statusNames[order.status] ?? "")),
              ),              
              Padding
              (
                padding: EdgeInsets.all(7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Order Placed • ", style: TextStyle(fontWeight: FontWeight.w300)),
                    Text(getDateText(order.date), style: TextStyle(fontWeight: FontWeight.w300)),
                  ]
                )
              ),
              Expanded(child: Container(),),
              Divider(thickness: 2,),
              Padding
              (
                padding: EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>
                  [
                    Text(order.products.length.toString() +  " item(s)"),
                    Text(order.price, style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              RaisedButton(
                onPressed: () => onOrderAgain(order),
                child: Container(
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  child: Center(child: Text("Order Again")),
                )
              )
            ]
          )
        )
      ),
    );
  }
}