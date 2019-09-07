import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";
import "package:bevvymobile/productScreen.dart";

typedef void AddToBasketFunc(Product product, int quantity);

//Displayed in the main list views
class ProductWidget extends StatelessWidget
{
  const ProductWidget({ Key key, this.product, this.checkoutData, this.addToBasket} ) : super(key: key);

  final Product product;
  final Map<Product, int> checkoutData;
  final AddToBasketFunc addToBasket;

  @override
  Widget build(BuildContext context) {
    return Align(
    alignment: Alignment.topLeft,
    child: 
      FlatButton
      (
        onPressed: ()
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(product: product, checkoutData: checkoutData, addToBasket: addToBasket,)));
        },
        child: Container
        (
          decoration: BoxDecoration
          (
            border: Border.all(color: Colors.black),
          ),
          width: imageSize + 50,
          height: imageSize + 50,
          alignment: Alignment(0,0),
          margin: EdgeInsets.all(3),
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
                ),
              ),
              product.icon,
              Container
              (
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Row
                (
                  children: [Text(product.price)]
                )
              )
            ]
          ),
        )
      )
    );
  }
}