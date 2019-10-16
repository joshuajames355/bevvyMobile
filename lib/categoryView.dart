import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import "productWidget.dart";

class CategoryView extends StatelessWidget
{
  const CategoryView({ Key key, this.productList, this.categories, this.currentCategory}) : super(key: key);

  final List<Product> productList;
  final List<String> categories;
  final int currentCategory;

  @override
  Widget build(BuildContext context) {
    return Column
    (
      children:
      [
        Padding
        (
          padding: EdgeInsets.only(top: 10),
          child: Row
          (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            [
              currentCategory > 0 ? FlatButton
              (
                
                onPressed: ()
                {

                },
                child: Padding
                (
                  padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 0),
                  child: Row
                  (
                    children: <Widget>
                    [
                      Icon(IconData(58820, fontFamily: 'MaterialIcons')),
                      Text(categories[currentCategory-1])
                    ],
                  ),
                )
              ) : Container(width: 150),
              Text
              (
                categories[currentCategory],
                style: TextStyle(fontSize: 24),
              ),
              currentCategory < categories.length - 1 ? FlatButton
              (
                onPressed: ()
                {

                },
                child: Padding
                (
                  padding: EdgeInsets.only(top: 15, bottom: 15, right: 0, left: 15),child: Row
                  (
                    children: <Widget>
                    [
                      Text(categories[currentCategory+1]),
                      Icon(IconData(58824, fontFamily: 'MaterialIcons')),
                    ],
                  ),
                ),
              ) : Container(width: 150,),
            ]
          )
        ),
        Expanded
        ( 
          child: ListView
          (
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