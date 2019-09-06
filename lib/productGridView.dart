import 'package:bevvymobile/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "productWidget.dart";

//Renders a List of all products, seperated by categories.
class ProductGridView extends StatelessWidget
{
  const ProductGridView({ Key key, this.productList}) : super(key: key);

  final List<Product> productList;

  @override
  Widget build(BuildContext context) {
    return GridView.count
    (
      crossAxisCount: 2,
      children: productList.map((Product x) 
      {
        return Container
        (
          margin: EdgeInsets.all(10),
          child: ProductWidget(product: x)
        );
        }).toList()
    );
  }
}