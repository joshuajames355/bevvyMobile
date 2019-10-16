import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/addressDialog.dart';
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
  AddressInformation currentAddress = AddressInformation.blank();
  String paymentMethod = "cash";

  void newAddress(AddressInformation newAddress)
  {
    setState(() {
      currentAddress = newAddress;
    });
  }

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
            Container
            (
              margin: EdgeInsets.symmetric(vertical: 12),
              child: Align
              (
                child: Text("Total: £" + getTotal(widget.checkoutData).toStringAsFixed(2), style: TextStyle(fontSize: 16),),
                alignment: Alignment.centerLeft,
              )
            ),
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
            Container
            (
              margin: EdgeInsets.all(10),
              child: DropdownButton
              (
                icon: Icon(Icons.arrow_downward),
                value: paymentMethod,
                onChanged: (String newValue)
                {
                  setState(() {
                    paymentMethod = newValue; 
                  });
                },
                items: <DropdownMenuItem<String>>
                [
                  DropdownMenuItem<String>
                  (
                    child: Text("Pay With Cash"),
                    value: "cash",
                  ),
                  DropdownMenuItem<String>
                  (
                    child: Text("Pay By Card"),
                    value: "card",
                  )
                ], 
              ), 
            ),
            Expanded(
              child: TextField
                (
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5)
                    ),
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
      )
    );
  }
}