import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";

//Displayed in the main list views
class ProductWidgetSquare extends StatelessWidget
{
  const ProductWidgetSquare({ Key key, this.product} ) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox
    (
      width: 180,
      height: 180,
      child: Hero
      (
        tag: product.id,
        child: Card
        (
          child: FlatButton
          (
            onPressed: ()
            {
              Navigator.pushNamed(context, "/product", arguments: product);
            },
            //padding: EdgeInsets.only(top: 10),
            
            child: Column
            (
              children: <Widget>
              [
                SizedBox.fromSize
                (
                  child: product.icon,
                  size: Size(180,138),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(child: Text(product.title, overflow: TextOverflow.ellipsis,))
                )
              ],
            )        
          )
        )
      )
    );
  }
}