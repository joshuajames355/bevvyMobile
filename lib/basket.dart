import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/checkout.dart';
import 'package:flutter/material.dart';

typedef void RemoveFromBasketFunc(Product product);

class BasketDataWidget extends StatelessWidget
{
  const BasketDataWidget({ Key key, this.product, this.checkoutData, this.removeFromBasket}) : super(key: key);

  final Product product;
  final Map<Product, int> checkoutData;
  final RemoveFromBasketFunc removeFromBasket;

  @override
  Widget build(BuildContext context) 
  {
    return Row(
      children: <Widget>
      [
        Expanded(
          child: Text(checkoutData[product].toString() + " X " + this.product.title,
            style: TextStyle(fontSize: 18),
        )),
        FloatingActionButton
        (
          heroTag: product.title,
          mini: true,
          onPressed: ()
          {
            removeFromBasket(product);
          },
          child: Icon(IconData(57691, fontFamily: 'MaterialIcons')),
          )
      ],
    );
  }
}

class Basket extends StatelessWidget
{
  const Basket({ Key key, this.checkoutData, this.removeFromBasket}) : super(key: key);

  final Map<Product, int> checkoutData;
  final RemoveFromBasketFunc removeFromBasket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Basket"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container
      (
        margin: EdgeInsets.all(25),
        child: Column
        (
          children: [
            Expanded
            (
              child: ListView
              (children: checkoutData.keys.map((Product x) => BasketDataWidget(product: x,checkoutData: checkoutData, removeFromBasket: removeFromBasket,)).toList(),
              ),
            ),
            RaisedButton
            (
              child:  Container
              (
                child: Center
                (
                  child: Text("Proceed To Checkout", style: TextStyle(fontSize: 18),)
                  ),
                width: double.infinity,
              ),
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Checkout()));
              },
            )
            ]
        )
      )
    );
  }
}