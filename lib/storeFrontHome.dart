import 'package:bevvymobile/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//Renders a List of all products, seperated by categories.
class StoreFrontHome extends StatelessWidget
{
  const StoreFrontHome({ Key key, this.productListByCategory}) : super(key: key);

  final Map<String, List<Product>> productListByCategory;

  @override
  Widget build(BuildContext context) {
    return ListView
      (
        children: productListByCategory.keys.toList().map((String category)
        {
          List<Product> products = productListByCategory[category];
          return Container
          (
            child: Column
            (
              children: <Widget>[
                Center
                (
                  child: Container
                  (
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Text
                    (
                      category,
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ),
                Container
                (
                  height: 170, //Todo, work out why removing this breaks the app.
                  child: ListView
                  (
                    scrollDirection: Axis.horizontal,
                    children: products.map((Product x)
                    {
                      return ProductWidget(product: x);
                    }).toList()
                  ),
                )
              ],
            ),
          );
        }).toList()
      );
  }
}