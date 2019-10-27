import 'package:bevvymobile/basket.dart';
import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";
import "package:bevvymobile/order.dart";
import 'package:bevvymobile/dataStore.dart';

class OrderScreen extends StatefulWidget
{
  const OrderScreen({ Key key, this.order, this.dataStore}) : super(key: key);

  final Order order;
  final DataStore dataStore;

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Order: " + widget.dataStore.orderRef.documentID),
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
                      children: widget.dataStore.order.data['basket'].keys.map(
                        (String productID) => Text(
                          " - " +  productID + " X " + widget.dataStore.order.data['basket'][productID], 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18),)
                      ),
                    )
                  ),
                ),           
                Container
                (
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  child: Row
                  (
                    children: [Text("Total: " + widget.dataStore.orderAmountStringWithCurrency, style: TextStyle(fontSize: 16))]
                  )
                ),
                Container
                (
                  margin: EdgeInsets.fromLTRB(25, 20, 25, 0),
                  child: Row
                  (
                    children: [Text("Status: " + widget.dataStore.order.data['status'], style: TextStyle(fontSize: 16))]
                  )
                ),
              ]
            ),
          )
        )
    );    
  }
}