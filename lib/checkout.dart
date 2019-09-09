import 'package:flutter/material.dart';
import 'package:bevvymobile/addressDialog.dart';

class Checkout extends StatefulWidget
{
  const Checkout({ Key key}) : super(key: key);

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
      body: Column
      (
        children: 
        [
          RaisedButton
          (
            padding: EdgeInsets.all(25),
            child: Text("Address"),
            onPressed: ()
            {
              showDialog(context: context, builder: (BuildContext context){
                return AddressDialog(currentAddress: currentAddress, setAddress: newAddress,);
              });
            },
          ),
          Text("Address: " + currentAddress.addressSummary())
        ]
      ),
    );
  }
}