import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";

//Displayed in the main list views
class ProductWidget extends StatelessWidget
{
  const ProductWidget({ Key key, this.product} ) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Hero
    (
      tag: product.id,
      child: Card(
        child: 
        FlatButton
        (
          onPressed: ()
          {
            Navigator.pushNamed(context, "/product", arguments: product);
          },
          padding: EdgeInsets.all(5),
          
          child: Container
          (
            width: imageSize + 50,
            height: imageSize + 100,
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center
                (
                  child: Text
                  (
                    product.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Center
                (
                  child: Text
                  (
                    product.size + "•" + product.priceCategory + "•" + product.category,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded
                (
                  child: product.icon
                ),
                Container
                (
                  margin: EdgeInsets.all(5),
                  child: Row
                  (
                    children: [Text("£" + product.price.toStringAsFixed(2), style: TextStyle(fontSize: 12),)]
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}