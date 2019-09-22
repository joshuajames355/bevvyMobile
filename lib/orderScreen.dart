import 'package:bevvymobile/basket.dart';
import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";
import "package:bevvymobile/order.dart";
import 'package:intl/intl.dart';

typedef void AddToBasketFunc(Product product, int quantity);

class OrderScreen extends StatefulWidget
{
  const OrderScreen({ Key key, this.order}) : super(key: key);

  final Order order;

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>{
  int count = 1;
  final DateFormat formatter = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Order: ORDER_ID"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
          ),
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: 
          Container
          (
            decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
            alignment: Alignment(0,0),
            child: Column
            (
              children: [
                Expanded
                (
                  child: Container
                  (
                    margin: EdgeInsets.all(25),
                    child: ListView
                    (
                      children: widget.order.products.keys.map((Product product)
                      {
                        return Text
                        (
                          " - " +  widget.order.products[product].toString() + " X " + product.title, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18),);
                      }).toList(),
                    )
                  ),
                ),           
                Container
                (
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  child: Row
                  (
                    children: [Text("Total: £" + getTotal(widget.order.products).toStringAsFixed(2), style: TextStyle(fontSize: 16))]
                  )
                ),
                Container
                (
                  margin: EdgeInsets.fromLTRB(25, 20, 25, 0),
                  child: Row
                  (
                    children: [Text("Status: " + widget.order.status, style: TextStyle(fontSize: 16))]
                  )
                ),
                Container
                (
                  margin: EdgeInsets.fromLTRB(25, 20, 25, 25),
                  child: Row
                  (
                    children: [Text("Arriving at: " + formatter.format(widget.order.arrivalTime), style: TextStyle(fontSize: 16),)]
                  )
                ),
              ]
            ),
          )
        )
    );    
  }
}