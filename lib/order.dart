import 'package:bevvymobile/product.dart';

class Order
{
  Order({this.status, this.products, this.arrivalTime});

  final String status;
  Map<Product, int> products; //Product : Quantity
  DateTime arrivalTime;

  String getTimeLeft()
  {
    final Duration timeLeft = arrivalTime.difference(DateTime.now());
    String response = "Arriving in ";
    if(timeLeft.inHours > 1)
    {
      response += timeLeft.inHours.toString() + " Hours";
    }
    response += timeLeft.inMinutes.toString() + " Minutes";
    return response;
  }
}