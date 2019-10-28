class Order
{
  Order({this.status, this.products, this.orderID});

  final String status;
  final String orderID;
  Map<String, int> products; //ProductId : Quantity

  Order.fromFirestore({Map<String, dynamic> data, this.orderID}) : 
    status = data["status"] ?? "",
    products = Map<String, int>.from(data["basket"]) ??  Map<String, int>();
}