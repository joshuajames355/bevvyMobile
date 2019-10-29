import 'package:flutter/material.dart';
import "package:bevvymobile/order.dart";

class OrderScreen extends StatefulWidget
{
  const OrderScreen({ Key key, this.order}) : super(key: key);

  final Order order;

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Order: " + widget.order.orderID),
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
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Center(child: Text("Items", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
          ),
          Divider(),
          Expanded
          (
            child: Container
            (
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: ListView
              (
                children: widget.order.products.keys.map(
                  (String productID) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                    [
                      SizedBox(
                        width: 300,
                        child: Text(productID, overflow: TextOverflow.ellipsis)
                      ),
                      Text("x " + widget.order.products[productID].toString(), style: TextStyle(color: Theme.of(context).accentColor),) 
                    ]
                  )
                ).toList(),
              )
            ),
          ),        
          Divider(),
          Container
          (
            margin: EdgeInsets.fromLTRB(25, 5, 25, 5),
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: "),
                Text("£0.00", style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor))
              ]
            )
          ),
          Container
          (
            margin: EdgeInsets.fromLTRB(25, 5, 25, 25),
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status: "),
                Text(widget.order.status, style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor))
              ]
            )
          ),
        ]
      ),
    );    
  }
}