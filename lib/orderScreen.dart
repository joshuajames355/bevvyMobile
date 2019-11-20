import 'package:flutter/material.dart';
import "package:bevvymobile/order.dart";
import "package:bevvymobile/utils.dart";

typedef void OnOrderAgain(Order order);

class OrderScreen extends StatefulWidget
{
  const OrderScreen({ Key key, this.order, this.statusNames, this.onOrderAgain}) : super(key: key);

  final Order order;
  final Map<String, String> statusNames;
  final OnOrderAgain onOrderAgain;

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
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
          Center
          (
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Text(widget.statusNames[widget.order.status], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            )
          ),
          Card
          (
            margin: EdgeInsets.all(5),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row
              (
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(IconData(59485, fontFamily: 'MaterialIcons')),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                      [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text("Order ID ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(widget.order.orderID ?? "", )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Placed At", style: TextStyle(fontWeight: FontWeight.w300),),
                            Text(getDateText(widget.order.date)?? "", style: TextStyle(fontWeight: FontWeight.w300))
                          ],
                        ),
                      ]
                    ),
                  )
                ]
              )
            ),
          ),
          Divider(thickness: 2),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Item", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text("Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              ],),
          ),
          Expanded
          (
            child: Container
            (
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ListView
              (
                children: widget.order.products.map(
                  (OrderItem item) => Column
                  (
                    children:
                    [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          SizedBox(
                            width: 300,
                            child: 
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                              [
                                Text(item.quantity.toString() + " × ", style: TextStyle(fontWeight: FontWeight.w300),),
                                Expanded(
                                  child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w300),),
                                ),
                              ]
                            ),
                          ),
                          Text("£" + (item.price.toDouble() * item.quantity/100).toStringAsFixed(2), style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.w300)) 
                        ]
                      )
                    ]
                  )
                ).toList(),
              )
            ),
          ),        
          Divider(thickness: 2,),
          Container
          (
            margin: EdgeInsets.fromLTRB(25, 5, 25, 5),
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TOTAL PAID", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text(widget.order.price, style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16, fontWeight: FontWeight.bold))
              ]
            )
          ),
          Divider(thickness: 2,),
          RaisedButton(
            onPressed: () => widget.onOrderAgain(widget.order),
            child: Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              child: Center(child: Text("Order Again")),
            )
          )
        ]
      ),
    );    
  }
}