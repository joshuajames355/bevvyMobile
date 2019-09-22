import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/orderWidget.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/productWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef void OnSelectCategory(String category);
typedef void AddToBasketFunc(Product product, int quantity);

//Renders a List of all products, seperated by categories.
class StoreFrontHome extends StatelessWidget
{
  const StoreFrontHome({ Key key, this.productListByCategory, this.onSelectCategory, this.addToBasket, this.orders}) : super(key: key);

  final Map<String, List<Product>> productListByCategory;
  final OnSelectCategory onSelectCategory;
  final AddToBasketFunc addToBasket;
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if(orders.length > 0)
    {
      children.add(makeSection("Orders", orders.map((Order order) => OrderWidget(order: order,)).toList()));
    }
    children.addAll(productListByCategory.keys.toList().map((String category)
    {
      return makeSection(category, productListByCategory[category].map((Product product) => ProductWidget(addToBasket: addToBasket, product: product,)).toList());
    }));
    return ListView
      (
        children: children
      );
  }

  Widget makeSection(String title, List<Widget> content)
  {
    return Container
    (
      child: Column
      (
        children: <Widget>[
          Center
          (
            child: Container
            (
              child: SizedBox
              (
                width: double.infinity,
                child: FlatButton(
                  child: Padding
                  (
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text
                    (
                      title,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  onPressed: ()
                  {
                    onSelectCategory(title);
                  },
                )
              )
            )
          ),
          Container
          (
            height: 200, //Todo, work out why removing this breaks the app.
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