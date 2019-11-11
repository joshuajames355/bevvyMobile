import 'package:bevvymobile/myOrders.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/productWidgetSquare.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef void GotoMyOrders();

//Renders a List of all products, seperated by categories.
class StoreFrontHome extends StatelessWidget
{
  const StoreFrontHome({ Key key, this.productListByCategory, this.orders, this.gotoMyOrders, this.statusNames, this.onOrderAgain}) : super(key: key);

  final Map<String, List<Product>> productListByCategory;
  final List<Order> orders;
  final GotoMyOrders gotoMyOrders;
  final Map<String, String> statusNames;
  final OnOrderAgain onOrderAgain;

  @override
  Widget build(BuildContext context) {
    var content = [orderSection(context)];
    content.addAll(productListByCategory.keys.toList().map((String category)
    {
      return makeSection(category, productListByCategory[category].map((Product product) =>  ProductWidgetSquare(product: product,)).toList(), context);
    }));
    
    return Scaffold (
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>
        [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/search"),
            icon: Icon(IconData(59574, fontFamily: 'MaterialIcons')),
          )
        ],
      ),
      body: ListView
      (
        children: joinElements(content)
      )
    );
  }

  Widget orderSection(BuildContext context)
  {
    if(orders == null || orders.length == 0) return Container();
    
    List<Order> validOrders = orders.where((Order order) => ![ "new_order", "synced_editing_order", "stripe_paymentintent_payment_failed"].contains(order.status)).toList();
    if(validOrders.length == 0) return Container();

    List<Order> ordersToDisplay = validOrders.where((Order order) => ["dispatch_queue", "delayed_queue", "out_for_delivery"].contains(order.status)).toList();
    String title = "Your Order(s) are coming";
    if(ordersToDisplay.length == 0)
    {
      ordersToDisplay = validOrders;
      title = "Order Again";
    }

    return Container
    (
      child: Column
      (
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(title, style: TextStyle(fontSize: 20)),
                ),
                FlatButton(
                  onPressed: (){
                    gotoMyOrders();
                  },
                  child: Text("See All", style: TextStyle(color: Theme.of(context).accentColor))
                )
              ],
            )
          ),
          Container
          (
            height: 200,
            child: ListView
            (
              scrollDirection: Axis.horizontal,
              children: ordersToDisplay.map((Order order) => Container(width: 300, child: OrderWidget(onOrderAgain: onOrderAgain, order: order, statusNames: statusNames,))).toList()
            ),
          )
        ],
      ),
    );
  }

  Widget makeSection(String title, List<Widget> content, BuildContext context)
  {
    return Container
    (
      child: Column
      (
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(title, style: TextStyle(fontSize: 20)),
                ),
                FlatButton(
                  onPressed: (){
                    Navigator.pushNamed(context, "/category", arguments: title);
                  },
                  child: Text("See All", style: TextStyle(color: Theme.of(context).accentColor))
                )
              ],
            )
          ),
          Container
          (
            height: 200,
            child: ListView
            (
              scrollDirection: Axis.horizontal,
              children: content
            ),
          )
        ],
      ),
    );
  }
}

List<Widget> joinElements(List<Widget> elements)
{
  if(elements.length == 0) return [];

  List<Widget> joinedElements = [elements[0]];
  for(int x = 1; x < elements.length; x++) 
  {
    joinedElements.addAll([Divider(height: 30, thickness: 2,), elements[x]]);
  }
  return joinedElements;
}