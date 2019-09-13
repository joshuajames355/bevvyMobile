import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/addressDialog.dart';

typedef void AddOrder(Order order);

class Checkout extends StatefulWidget
{
  const Checkout({ Key key, this.onAddOrder, this.checkoutData}) : super(key: key);

  final AddOrder onAddOrder;
  final Map<Product, int> checkoutData; //List of products/quantities

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> 
{
  AddressInformation currentAddress = AddressInformation.blank();

  void newAddress(AddressInformation newAddress)
  {
    setState(() {
      currentAddress = newAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: Column
        (
          children: 
          [
            Container
            (
              margin: EdgeInsets.symmetric(vertical: 12),
              child: Align
              (
                child: Text("Delivery Address: " + currentAddress.addressSummary(), style: TextStyle(fontSize: 16),),
                alignment: Alignment.centerLeft,
              )
            ),
            RaisedButton
            (
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(12),
              child: Container
              (
                width: double.infinity,
                child: Center(child: Text("Change Address")),
              ),
              onPressed: ()
              {
                showDialog(context: context, builder: (BuildContext context){
                  return AddressDialog(currentAddress: currentAddress, setAddress: newAddress,);
                });
              },
            ),
            Expanded(child: Container(),), //Just Fill space
            RaisedButton
            (
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(12),
              child: Container
              (
                width: double.infinity,
                child: Center(child: Text("Purchase")),
              ),
              onPressed: ()
              {
                widget.onAddOrder(new Order(products: Map.from(widget.checkoutData), status: "Pending", arrivalTime: DateTime.now().add(new Duration(minutes: 20))));
                Navigator.popUntil(context, ModalRoute.withName("/"));
              },
            ),
          ]
        ),
      )
    );
  }
}