import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef void AddOrder(Order order);

class Checkout extends StatefulWidget
{
  const Checkout({ Key key, this.onAddOrder, this.checkoutData, this.location}) : super(key: key);

  final AddOrder onAddOrder;
  final Map<Product, int> checkoutData; //List of products/quantities
  final LatLng location;

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> 
{
  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text("Checkout"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ), 
      body: Container
      (
        padding: EdgeInsets.all(15),
        child: Column
        (
          children: 
          [ 
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: 
              [
                Text("Total", style: TextStyle(fontSize: 16)),
                Text("£" + (getTotal(widget.checkoutData) + (getTotal(widget.checkoutData) > 25 ? 0 : 3.50)).toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor)),
              ]
            ),
            Padding
            (
              padding: EdgeInsets.symmetric(vertical: 10),
              child: TextField
              (
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'House Number/Name',
                ),
              ),
            ),
            Padding
            (
              padding: EdgeInsets.symmetric(vertical: 10),
              child: TextField
              (
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Note to Driver',
                ),
              ),
            ),
            RaisedButton
            (
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(12),
              child: Container
              (
                width: double.infinity,
                child: Center(child: Text("Continue")),
              ),
              onPressed: ()
              {
                widget.onAddOrder(new Order(products: Map.from(widget.checkoutData), status: "Pending", arrivalTime: DateTime.now().add(new Duration(minutes: 20))));
                Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
              },
            ),
          ]
        ),
  Widget nativePayButton(BuildContext context)
  {
    if(Platform.isAndroid)
    {
      return InkWell
      (
        onTap: ()
        {
          //TODO: google pay
          print("Whatever");
          Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
        },
        child: Container
        (
          height: 50,
          child: AndroidView
          (
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            viewType: 'GooglePayButton',
          )   
        )     
      );
    }
  }