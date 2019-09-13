import 'package:flutter/material.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';

class OrderWidget extends StatelessWidget
{
  const OrderWidget({ Key key, this.order} ) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return FlatButton
    (
      onPressed: (){},
      padding: EdgeInsets.all(5),
      child: Container
      (
        decoration: BoxDecoration
        (
          borderRadius: new BorderRadius.all(Radius.circular(12)),
          color: Theme.of(context).primaryColorLight,
        ),
        width: imageSize + 120,
        height: imageSize + 100,
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text
            (
              order.getTimeLeft(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),

            ),
            Text
            (
              order.status,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18),
            ),
            Container
            (
              child: Column
              (
                children: order.products.keys.map((Product product)
                {
                  return Text(" - " + order.products[product].toString() + " X " + product.title);
                }).toList(),
              ),
            )
          ]
        )
      )
    );
  }
}