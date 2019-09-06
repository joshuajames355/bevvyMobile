import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/productWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef void OnSelectCategory(String category);

//Renders a List of all products, seperated by categories.
class StoreFrontHome extends StatelessWidget
{
  const StoreFrontHome({ Key key, this.productListByCategory, this.onSelectCategory}) : super(key: key);

  final Map<String, List<Product>> productListByCategory;
  final OnSelectCategory onSelectCategory;

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
                    child: SizedBox
                    (
                      width: double.infinity,
                      child: FlatButton(
                        child: Padding
                        (
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text
                          (
                            category,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        onPressed: ()
                        {
                          onSelectCategory(category);
                        },
                      )
                    )
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