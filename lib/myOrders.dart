import 'package:bevvymobile/order.dart';
import 'package:flutter/material.dart';

class MyOrders extends StatelessWidget
{
  const MyOrders({Key key, this.orders}) : super(key: key);

  final List<Order> orders;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        leading: FlatButton(
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: orders.where((Order order) => order.status != "new_order" && order.status != "synced_editing_order").map((Order order) => Card(
            child: FlatButton(
              onPressed: () => Navigator.pushNamed(context, "/order", arguments: order.orderID),
              child: Text(order.orderID)
            ),
          )
        ).toList()
      ),
    );
  }
}