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
      body: ListView
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
                            Text("Placed", style: TextStyle(fontWeight: FontWeight.w300),),
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
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Item", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text("Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              ],),
          ),
          Container
          (
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column
            (
              mainAxisSize: MainAxisSize.min,
              children: widget.order.products.map<Widget>(
                (OrderItem item) => Column
                (
                  children:
                  [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
              ).toList()..add(
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Subtotal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),),
                      Text("£" + (widget.order.products.map((OrderItem item) => item.price * item.quantity).reduce((int a, int b) => a+b).toDouble()/100).toStringAsFixed(2), style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold, fontSize: 14.5))
                    ],
                  )
                )
              ),
            )
          ),
          Divider(thickness: 2,),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Other Charges", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text("Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              ],),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
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
                          Expanded(
                            child: Text("Delivery Fee", style: TextStyle(fontWeight: FontWeight.w300),),
                          ),
                        ]
                      ),
                    ),
                    Text("£3.50" , style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.w300)) 
                  ]
                )
              ],
            ),
          ),
          Divider(thickness: 2,),
          Container
          (
            margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Paid", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text(widget.order.price, style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16, fontWeight: FontWeight.bold))
              ]
            )
          ),
          widget.order.paymentInfo.isEmpty ? Container(): Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Paid with", style: TextStyle(fontWeight: FontWeight.w300),),
                  Container(
                    child: Row(
                      children: <Widget>[
                        getCardBrandIcon(widget.order.paymentInfo["brand"] ?? ""),
                        Padding(
                          child: Text("ending in " + widget.order.paymentInfo["last4"] ?? "****", style: TextStyle(fontWeight: FontWeight.w300),),
                          padding: EdgeInsets.only(left: 10),
                        )
                  ],
                  ),
                  ),
              ],),
          ),
          Divider(thickness: 2, height: 40,),
          RaisedButton(
            onPressed: () => widget.onOrderAgain(widget.order),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(12),
                width: double.infinity,
                child: Center(child: Text("Order Again")),
              )
            )
          )
        ]
      ),
    );    
  }
}