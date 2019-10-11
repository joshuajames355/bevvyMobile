import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import "productWidget.dart";

class CategoryView extends StatelessWidget
{
  const CategoryView({ Key key, this.productList, this.category}) : super(key: key);

  final List<Product> productList;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Column
    (
      children:
      [
        Padding
        (
          padding: EdgeInsets.only(top: 10),
          child: Text
          (
            category,
            style: TextStyle(fontSize: 24),
          ),
        ),
        Expanded
        ( 
          child: GridView.count
          (
            crossAxisCount: 2,
            padding: EdgeInsets.symmetric(vertical: 10),
            children: productList.map((Product x) 
            {
              return ProductWidget(product: x, );
            }).toList()
          )
        )
      ]
    );
  }
}