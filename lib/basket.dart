import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';

typedef void RemoveFromBasketFunc(Product product);
typedef void AddOrder(Order order);

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
          child: Row(
            children: <Widget>
            [
              Flexible
              (
                child:  Text(checkoutData[product].toString() + " X " + this.product.title,
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                )
              ),
              Text("£" + (checkoutData[product] * product.price).toStringAsFixed(2),style: TextStyle(fontSize: 18),)
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          )          
        ),
        Container
        (
          margin: EdgeInsets.only(left: 15),
          child: FloatingActionButton
          (
            heroTag: product.title,
            mini: true,
            onPressed: ()
            {
              removeFromBasket(product);
            },
            child: Icon(IconData(57691, fontFamily: 'MaterialIcons')),
          )
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
        padding: EdgeInsets.all(25),
        color: Theme.of(context).backgroundColor,
        child: Column
        (
          children: [
            Expanded
            (
              child: ListView
              (children: checkoutData.keys.map((Product x) => BasketDataWidget(product: x,checkoutData: checkoutData, removeFromBasket: removeFromBasket,)).toList(),
              ),
            ),
            Container
            (
              margin: EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.centerLeft,
              child: Text("Total: £" + getTotal(checkoutData).toStringAsFixed(2), style: TextStyle(fontSize: 18),),
            ),
            RaisedButton
            (
              color: Theme.of(context).primaryColor,
              child:  Container
              (
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center
                (
                  child: Text("Proceed To Checkout", style: TextStyle(fontSize: 18),)
                  ),
                width: double.infinity,
              ),
              onPressed: ()
              {
                if(checkoutData.length == 0)
                {
                  showDialog(context: context, builder: (context) => AlertDialog(title: Text("The Basket is Empty"), content: Text("Add at least on item to your basket.")));
                }
                else
                {                
                  Navigator.pushNamed(context, "/checkout");
                }
              },
            )
            ]
        )
      )
    );
  }
}

double getTotal(Map<Product, int> basket)
{
  double total = 0;
  basket.forEach((Product k, int quantity){
    total += k.price * quantity;
  });
  return total;
}