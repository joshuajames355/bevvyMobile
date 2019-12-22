import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/utils.dart';
import 'package:flutter/material.dart';

typedef void OnOrderAgain(Order order);

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
                    Text(order.products.length.toString() + (order.products.length == 1 ? " item" : " items")),
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