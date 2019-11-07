class Order
{
  const Order({this.status, this.products, this.orderID, this.price, this.date});

  final String status;
  final String orderID;
  final String price; //Including currency
  final DateTime date;
  final Map<String, int> products; //ProductId : Quantity

  Order.fromFirestore({Map<String, dynamic> data, this.orderID}) : 
    status = data["status"] ?? "",
    products = Map<String, int>.from(data["basket"]) ??  Map<String, int>() ,
    price = "£" + (((data["serverOrderTotal"] ?? 0.0)/100) as double).toStringAsFixed(2),
    date = data["updatedLastByUserAt"] == null ? DateTime.now() : data["updatedLastByUserAt"].toDate();
}