import 'package:cloud_firestore/cloud_firestore.dart';

class Order
{
  const Order({this.status, this.products, this.otherCharges, this.orderID, this.serverOrderTotal, this.date, this.paymentInfo});

  final String status;
  final String orderID;
  final String serverOrderTotal; //Including currency
  final DateTime date;
  final Map<String, String> paymentInfo;
  final List<OrderItem> products;
  final List<OtherChargeItem> otherCharges;

  Order.fromFirestore({Map<String, dynamic> data, this.orderID}) : 
    status = (data["status"] != null && data["status"] is String) ? data["status"] : "",
    products = List.from((data["basket"] ?? []).map<OrderItem>((dynamic item) => OrderItem(Map<String, dynamic>.from(item)))),
    otherCharges = List.from((data["othercharges"] ?? []).map<OtherChargeItem>((dynamic item) => OtherChargeItem(Map<String, dynamic>.from(item)))),
    serverOrderTotal = "£" + ((((data["serverOrderTotal"] != null && data["serverOrderTotal"] is int) ? data["serverOrderTotal"] : 0)/100) as double).toStringAsFixed(2),
    date = (data["updatedLastByUserAt"] == null || !(data["updatedLastByUserAt"] is Timestamp)) ? DateTime.now() : data["updatedLastByUserAt"].toDate(),
    paymentInfo = (data["paymentInfo"] == null || !(data["paymentInfo"] is Map)) ? {} : Map<String, String>.from(data["paymentInfo"]);
  
  int get basketSubtotal{
    int basketSubtotal = 0;
    this.products.forEach((OrderItem k){
      basketSubtotal += k.price * k.quantity;
    });
    return basketSubtotal;
  }
}

class OrderItem
{
  final String name;
  final int price;
  final String id;
  final int quantity;

  OrderItem(Map<String, dynamic> data) :
    name = data["name"] ?? "",
    id = data["id"] ?? "",
    price = data["price"] ?? 0,
    quantity = data["quantity"] ?? 0;
}

class OtherChargeItem
{
  final String name;
  final String type;
  final int value;

  OtherChargeItem(Map<String, dynamic> data) :
    name = data["name"] ?? "",
    type = data["type"] ?? "",
    value = data["value"] ?? 0;
  
  String get printValue{
      if (this.type == 'fixed_amount') {
        if (this.value > 0) {
          return "£" + (this.value/100).toStringAsFixed(2);
        } else {
          return "−£" + (-this.value/100).toStringAsFixed(2);
        }
      } else if (this.type == 'percentage_basket') {
        return this.value.toString()+"%";
      } else if (this.type == 'percentage_total') {
        return this.value.toString()+"%";
      }
    return "";
  }
}
