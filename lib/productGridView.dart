import 'package:bevvymobile/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "productWidget.dart";

typedef void AddToBasketFunc(Product product, int quantity);

//Renders a List of all products, seperated by categories.
class ProductGridView extends StatelessWidget
{
  const ProductGridView({ Key key, this.productList, this.checkoutData, this.addToBasket}) : super(key: key);

  final List<Product> productList;
  final Map<Product, int> checkoutData;
  final AddToBasketFunc addToBasket;

  @override
  Widget build(BuildContext context) {
    return GridView.count
    (
      crossAxisCount: 2,
      padding: EdgeInsets.all(10),
      children: productList.map((Product x) 
      {
        return ProductWidget(product: x, checkoutData: checkoutData, addToBasket: addToBasket);
      }).toList()
    );
  }
}