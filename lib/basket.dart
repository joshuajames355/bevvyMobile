import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';

typedef void RemoveFromBasketFunc(String productID);
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
    return Padding
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
                  Text(checkoutData[product].toString() + "X",),
                ],
              )
            ),
          ),
          SizedBox.fromSize
          (
            child: Center
            (
              child: Text("£" + (checkoutData[product] * product.price).toStringAsFixed(2), style: TextStyle(color: Theme.of(context).accentColor)),
            ),
            size: Size(75,75),
          ),
        ],
      )
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
        title: Text("Basket (" + checkoutData.length.toString() + ")"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column
      (
        children: [
          Expanded
          (
            child: Padding
            (
              padding: EdgeInsets.symmetric(vertical: 12),
              child: ListView
              (
                children: joinBasketElements
                (
                  checkoutData.keys.map((Product x) => Dismissible 
                    (
                      key: Key(x.id),
                      child: BasketDataWidget(product: x,checkoutData: checkoutData, removeFromBasket: removeFromBasket,),
                      onDismissed: (DismissDirection direction)
                      {
                        removeFromBasket(x.id);
                      },
                      direction: DismissDirection.endToStart,
                      background: Container
                      (
                        decoration: BoxDecoration(color: Colors.red),
                        child: Row
                        (
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>
                          [
                            Expanded(child: Container(),),
                            Padding
                            (
                              padding: EdgeInsets.all(20),
                              child: Icon(IconData(58829, fontFamily: 'MaterialIcons')),
                            ),
                          ],                        
                        ),
                      ),
                    ),
                  ).toList(),
                )
              ),
            ),
          ),
          RaisedButton
          (
            child:  Container
            (
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Center
              (
                child: Text("Proceed (£" + getTotal(checkoutData).toStringAsFixed(2) + ")", style: TextStyle(fontSize: 18),)
                ),
              width: double.infinity,
            ),
            onPressed: ()
            {
              if(checkoutData.length == 0)
              {
                showDialog(context: context, builder: (context) => AlertDialog(title: Text("The Basket is Empty"), content: Text("Add at least one item to your basket.")));
              }
              else
              {                
                Navigator.pushNamed(context, "/checkout");
              }
            },
          )
        ]
      )
    );
  }
}
List<Widget> joinBasketElements(List<Widget> basketElements)
{
  if(basketElements.length == 0) return [];

  List<Widget> joinedElements = [basketElements[0]];
  for(int x = 1; x < basketElements.length; x++) 
  {
    joinedElements.addAll([Divider(height: 30, thickness: 2,), basketElements[x]]);
  }
  return joinedElements;
}

double getTotal(Map<Product, int> basket)
{
  double total = 0;
  basket.forEach((Product k, int quantity){
    total += k.price * quantity;
  });
  return total;
}