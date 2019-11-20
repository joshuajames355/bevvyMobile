import 'package:cloud_firestore/cloud_firestore.dart';

class Order
{
  const Order({this.status, this.products, this.orderID, this.price, this.date, this.paymentInfo});

  final String status;
  final String orderID;
  final String price; //Including currency
  final DateTime date;
  final Map<String, String> paymentInfo;
  final List<OrderItem> products;

  Order.fromFirestore({Map<String, dynamic> data, this.orderID}) : 
    status = (data["status"] != null && data["status"] is String) ? data["status"] : "",
    products = List.from((data["basket"] ?? []).map<OrderItem>((dynamic item) => OrderItem(Map<String, dynamic>.from(item)))),
    price = "£" + ((((data["serverOrderTotal"] != null && data["serverOrderTotal"] is int) ? data["serverOrderTotal"] : 0)/100) as double).toStringAsFixed(2),
    date = (data["updatedLastByUserAt"] == null || !(data["updatedLastByUserAt"] is Timestamp)) ? DateTime.now() : data["updatedLastByUserAt"].toDate(),
    paymentInfo = (data["paymentInfo"] == null || !(data["paymentInfo"] is Map)) ? {} : Map<String, String>.from(data["paymentInfo"]);
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