import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bevvymobile/dataStore.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef void RemoveFromBasketFunc(String productID);
typedef void AddProductFunc(Product product, int quantity);

typedef void AddOrder(Order order);

class BasketDataWidget extends StatelessWidget
{
  const BasketDataWidget({ Key key, this.product, this.dataStore, this.removeFromBasket, this.addProduct}) : super(key: key);

  final Product product;
  final DataStore dataStore;
  final RemoveFromBasketFunc removeFromBasket;
  final AddProductFunc addProduct;

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
            size: Size(80,80),
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
                  Text(product.title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 33,
                        child: FloatingActionButton(
                          onPressed: ()=>{addProduct(product, -1)},
                          child: Icon(IconData(0xe15b, fontFamily: 'MaterialIcons'), color: Colors.black, size: 19.0,),
                          backgroundColor: Colors.white,
                          ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text(dataStore.checkoutData[product].toString(), style: TextStyle(fontSize: 22.0)),
                      ),
                      SizedBox(
                        width: 33,
                        child: FloatingActionButton(
                          onPressed: ()=>{addProduct(product, 1)},
                          child: Icon(Icons.add, color: Colors.black, size: 19.0),
                          backgroundColor: Colors.white,
                          ),
                      ),
                    ],
                  ),
                ],
              )
            ),
          ),
          SizedBox.fromSize
          (
            child: Center
            (
              child: Text("£" + (dataStore.checkoutData[product] * product.priceAsDouble).toStringAsFixed(2), style: TextStyle(color: Theme.of(context).accentColor)),
            ),
            size: Size(50,50),
          ),
        ],
      )
    );
  }
}

class Basket extends StatefulWidget
{
  const Basket({ Key key, this.dataStore, this.removeFromBasket, this.addProduct, this.deliveryFee, this.freeDeliveryMinimun}) : super(key: key);

  final DataStore dataStore;
  final RemoveFromBasketFunc removeFromBasket;
  final AddProductFunc addProduct;
  final double deliveryFee;
  final double freeDeliveryMinimun;

  @override
  _BasketState createState() => _BasketState();
}

class _BasketState extends State<Basket> {
  int reference;
  @override
  void initState() {
    reference = this.widget.dataStore.subscribeToOrderUpdate((_) => this.setState(()=> _)); //Update UI on datastore update.
    super.initState();
  }

  @override
  void dispose() {
    this.widget.dataStore.unsubscribeFromOrderUpdates(reference);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Basket", style: TextStyle(fontFamily: "opificio"),),
        automaticallyImplyLeading: false,
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
                  widget.dataStore.checkoutData.keys.map((Product x) => Dismissible 
                    (
                      key: Key(x.id),
                      child: BasketDataWidget(product: x, dataStore: widget.dataStore, removeFromBasket: widget.removeFromBasket, addProduct: widget.addProduct,),
                      onDismissed: (DismissDirection direction)
                      {
                        widget.removeFromBasket(x.id);
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
                    Text(widget.dataStore.basketSubtotalStringWithCurrency, style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor)),
                  ]
                ),
              ]..addAll(this.widget.dataStore.otherCharges.map((OtherChargeItem item) => OtherChargesBasketElement(item)))..add(
              
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 
                  [
                    Text("Total", style: TextStyle(fontSize: 16)),
                    Text(widget.dataStore.orderAmountStringWithCurrency, style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor, fontStyle: this.widget.dataStore.isSynced ? FontStyle.normal : FontStyle.italic)),
                  ]
                ),
              )
            ),
          ),
          Card
          (
            child: Padding(
              padding: EdgeInsets.all(6),
              child: TextField(
                textInputAction: TextInputAction.go,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Promo Codes",
                ),
                onSubmitted: addPromoCode,
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
                child: Text("Go to Checkout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ),
              width: double.infinity,
            ),
            onPressed: () async
            {
              if (widget.dataStore.checkoutData.length == 0) {
                showPlatformDialog(androidBarrierDismissible: true,context: context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("The Basket is Empty"), content: Text("Add at least one item to your basket.")));
              } else {                
                try {
                  widget.dataStore.createOrUpdateFirestoreOrder();
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

  void addPromoCode(String code){
    this.widget.dataStore.addPromoCode(code);
  }
}

class OtherChargesBasketElement extends StatelessWidget
{
  const OtherChargesBasketElement(this.item, { Key key}) : super(key: key);

  final OtherChargeItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: 
      [
        Text(item.name, style: TextStyle(fontSize: 16)),
        Container
        (
          child: Row
          (
            children: 
            [
              Text(item.printValue, style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor))
            ]
          )
        ),
      ]
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