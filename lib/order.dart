class Order
{
  Order({this.status, this.products});

  final String status;
  Map<String, int> products; //ProductId : Quantity

  Order.fromFirestore({Map<String, dynamic> data}) : 
    status = data["status"] ?? "",
    products = data["basket"] ??  Map<String, int>();
}