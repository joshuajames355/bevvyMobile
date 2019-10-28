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
          Expanded
          (
            child: Container
            (
              margin: EdgeInsets.all(25),
              child: ListView
              (
                children: widget.order.products.keys.map(
                  (String productID) => Text(
                    " - " +  productID + " X " + widget.order.products[productID].toString(), 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18),)
                ).toList(),
              )
            ),
          ),        
          //Get total of order.   
          /*Container
          (
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Row
            (
              children: [Text("Total: " + widget.dataStore.orderAmountStringWithCurrency, style: TextStyle(fontSize: 16))]
            )
          ),*/
          Container
          (
            margin: EdgeInsets.fromLTRB(25, 20, 25, 25),
            child: Row
            (
              children: [Text("Status: " + widget.order.status, style: TextStyle(fontSize: 16))]
            )
          ),
        ]
      ),
    );    
  }
}