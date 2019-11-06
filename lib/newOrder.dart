import 'package:flutter/material.dart';
import "package:bevvymobile/dataStore.dart";

//Displayed in the main list views
class NewOrder extends StatefulWidget
{
  const NewOrder({ Key key, this.orderStatus, this.dataStore }) : super(key: key);

  final String orderStatus;
  final DataStore dataStore;

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder>
{

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    String message;
    if(widget.orderStatus == "edited_order") message = "Waiting For Server...";
    else if(widget.orderStatus == "dispatch_queue") message = "Order Confirmed!";
    else if(widget.orderStatus == "error") message = "An Unkown Error occured.";
    else if(widget.orderStatus == "timeout") message = "The connection timed out.";
    
    return Scaffold
    (
      appBar: AppBar(title: Text("Order: " + widget.dataStore.order.documentID),),
      body: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>
        [
          CircularProgressIndicator(),
          Padding
          (
            padding: EdgeInsets.all(50),
            child: Center(child: Text(message))
          ),
        ],
      )
    );
  }
}