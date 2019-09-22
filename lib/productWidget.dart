import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";
import "package:bevvymobile/productScreen.dart";

typedef void AddToBasketFunc(Product product, int quantity);

//Displayed in the main list views
class ProductWidget extends StatelessWidget
{
  const ProductWidget({ Key key, this.product, this.addToBasket} ) : super(key: key);

  final Product product;
  final AddToBasketFunc addToBasket;

  @override
  Widget build(BuildContext context) {
    return FlatButton
    (
      onPressed: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(product: product, addToBasket: addToBasket,)));
      },
      padding: EdgeInsets.all(5),
      
      child: Container
      (
        decoration: BoxDecoration
        (
          borderRadius: new BorderRadius.all(Radius.circular(12)),
          color: Theme.of(context).primaryColorLight,
        ),
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
            Expanded(child: product.icon),
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
    );
  }
}