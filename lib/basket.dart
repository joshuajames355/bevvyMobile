import 'package:bevvymobile/homeNavBar.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/dataStore.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef void RemoveFromBasketFunc(String productID);
typedef void AddOrder(Order order);

class BasketDataWidget extends StatelessWidget
{
  const BasketDataWidget({ Key key, this.product, this.dataStore, this.removeFromBasket}) : super(key: key);

  final Product product;
  final DataStore dataStore;
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
            size: Size(50,50),
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
                  Text(dataStore.checkoutData[product].toString() + "X",),
                ],
              )
            ),
          ),
          SizedBox.fromSize
          (
            child: Center
            (
              child: Text("£" + (dataStore.checkoutData[product] * product.price).toStringAsFixed(2), style: TextStyle(color: Theme.of(context).accentColor)),
            ),
            size: Size(50,50),
          ),
        ],
      )
    );
  }
}

class Basket extends StatelessWidget
{
  const Basket({ Key key, this.dataStore, this.removeFromBasket}) : super(key: key);

  final DataStore dataStore;
  final RemoveFromBasketFunc removeFromBasket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Your Basket"),
      ),
      bottomNavigationBar: HomeNavBar(
        currentIndex: 1,
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
                  dataStore.checkoutData.keys.map((Product x) => Dismissible 
                    (
                      key: Key(x.id),
                      child: BasketDataWidget(product: x, dataStore: dataStore, removeFromBasket: removeFromBasket,),
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
                              padding: EdgeInsets.only(right: 20),
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
          Padding
          (
            padding: EdgeInsets.all(15),
            child: Column
            (
              children: <Widget>
              [
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 
                  [
                    Text("Subtotal", style: TextStyle(fontSize: 16)),
                    Text("£" + getTotal(dataStore.checkoutData).toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor)),
                  ]
                ),
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 
                  [
                    Text("Delivery fee", style: TextStyle(fontSize: 16)),
                    Container
                    (
                      child: Row
                      (
                        children: 
                        [
                          Padding
                          (
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: IconButton
                            (
                              icon: Icon(IconData(59534, fontFamily: 'MaterialIcons')),
                              onPressed: ()
                              {
                                showPlatformDialog(context: context, builder: (context) => PlatformAlertDialog(title: Text("Delivery fee"), content: Text("Free if you spend more than £25.")));
                              },
                            ),
                          ),
                          Text(getTotal(dataStore.checkoutData) > 25 ? "£0.00" : "£3.50", style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor))
                        ]
                      )
                    ),
                  ]
                ),
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 
                  [
                    Text("Total", style: TextStyle(fontSize: 16)),
                    Text("£" + (getTotal(dataStore.checkoutData) + (getTotal(dataStore.checkoutData) > 25 ? 0 : 3.50)).toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor)),
                  ]
                ),
              ],
            ),
          ),
          RaisedButton
          (
            child:  Container
            (
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Center
              (
                child: Text("Go to Checkout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ),
              width: double.infinity,
            ),
            onPressed: () async
            {
              if (dataStore.checkoutData.length == 0) {
                showPlatformDialog(context: context, builder: (context) => PlatformAlertDialog(title: Text("The Basket is Empty"), content: Text("Add at least one item to your basket.")));
              } else {                
                try {
                  dataStore.createOrUpdateFirestoreOrder();
                  Navigator.pushNamed(context, "/checkout");
                } catch (error) {
                  print(error);
                }
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