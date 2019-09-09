import 'package:flutter/material.dart';

typedef void SetAddress(AddressInformation newAddress);

class AddressInformation
{
  const AddressInformation({this.houseNumber, this.street, this.city, this.county, this.postcode});

  final String houseNumber; //Name or number
  final String street;
  final String city;
  final String county;
  final String postcode;

  AddressInformation.blank() : houseNumber="", street="", city="", county="", postcode="";

  String addressSummary()
  {
    return houseNumber + " " + street + " " + city;
  }
}

class AddressDialog extends StatefulWidget
{
  AddressDialog({Key key, this.currentAddress, this.setAddress}) : super(key : key);

  final AddressInformation currentAddress;
  final SetAddress setAddress;

  @override
  _AddressDialogState createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> 
{
  TextEditingController _houseNumberController;
  TextEditingController _houseStreetController;
  TextEditingController _cityController;
  TextEditingController _countyController;
  TextEditingController _postcodeController;

  @override
  void initState() {
    
    super.initState();

    _houseNumberController = TextEditingController(text: widget.currentAddress.houseNumber);
    _houseStreetController = TextEditingController(text: widget.currentAddress.street);
    _cityController = TextEditingController(text: widget.currentAddress.city);
    _countyController = TextEditingController(text: widget.currentAddress.county);
    _postcodeController = TextEditingController(text: widget.currentAddress.postcode);
  }

  @override 
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
      ),      
      child: Center(
        child: dialogContent(context),
      )
    );
  }

  Widget dialogContent(BuildContext context)
  {
    return Column
    (
      mainAxisSize: MainAxisSize.min,
      children: <Widget>
      [
        TextField
        (
          controller: _houseNumberController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'House Number',
          ),
        ),
        TextField
        (
          controller: _houseStreetController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'Street',
          ),              
        ),             
        TextField
        (
          controller: _cityController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'City',
          ),              
        ),
        TextField
        (
          controller: _countyController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'County',
          ),              
        ),
        TextField
        (
          controller: _postcodeController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'Postcode',
          ),              
        ),
        FlatButton
        (
          padding: EdgeInsets.symmetric(vertical: 25),
          child: Container
          (
            width: double.infinity, 
            child: Center(child: Text("Confirm"))
          ),
          onPressed: ()
            {
              widget.setAddress
              (
                AddressInformation
                (
                  city: _cityController.text,
                  street: _houseStreetController.text,
                  houseNumber: _houseNumberController.text,
                  postcode: _postcodeController.text,
                  county: _countyController.text
                )
              );
              Navigator.pop(context);
            },
        )
         
      ],
    );
  }
}