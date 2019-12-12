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
      child: Card
      (
        child: FlatButton
      (
        onPressed: ()
        {
          Navigator.pushNamed(context, "/product", arguments: product);
        },
        padding: EdgeInsets.all(5),
        
        child: Padding
        (
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row
          (
            children: <Widget>
            [
              SizedBox.fromSize
              (
                child: product.icon,
                size: Size(75,75),
              ),
              Expanded
              (
                child: Padding
                (
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column
                  (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                      Text(product.title, style: TextStyle( fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                      Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: 
                        [
                          Text(product.size)
                        ],
                      )
                    ],
                  )
                ),
              ),
              SizedBox.fromSize
              (
                child: Center
                (
                  child: Text(product.priceString, style: TextStyle(color: Theme.of(context).accentColor)),
                ),
                size: Size(75,75),
              ),
            ],
          )
        )
      ))
    );
  }
}