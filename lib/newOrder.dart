import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

//Displayed in the main list views
class NewOrder extends StatefulWidget
{
  const NewOrder({ Key key, this.orderStatus, this.orderID, this.statusNames }) : super(key: key);

  final String orderStatus;
  final Map<String, String> statusNames;
  final String orderID;

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
    else if(widget.statusNames.containsKey(widget.orderStatus)) message = widget.statusNames[widget.orderStatus];
    else if(widget.orderStatus == "dispatch_queue") message = "Order Confirmed!";
    else if(widget.orderStatus == "error") message = "An Unkown Error occured.";
    else if(widget.orderStatus == "timeout") message = "The connection timed out.";
    else if(widget.orderStatus == "error_card_declined") message = "Your Card was Declined.";
    else message = "This should never happen";
    
    return Scaffold
    (
      appBar: AppBar(title: Text("Order: " + widget.orderID, style: TextStyle(fontFamily: "opificio"))),
      body: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>
        [
          PlatformCircularProgressIndicator(ios: (_) => CupertinoProgressIndicatorData(radius: 20),),
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