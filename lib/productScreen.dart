import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";
import "dart:math";

typedef void AddToBasketFunc(Product product, int quantity);

class ProductScreen extends StatefulWidget
{
  const ProductScreen({ Key key, this.product, this.checkoutData, this.addToBasket}) : super(key: key);

  final Product product;
  final Map<Product, int>  checkoutData;
  final AddToBasketFunc addToBasket;

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>{
  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: Text(widget.product.title),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
          ),
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: 
          Container
          (
            alignment: Alignment(0,0),
            margin: EdgeInsets.all(3),
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                widget.product.iconLarge,
                Container
                (
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: Text(widget.product.description)
                ),
                Container
                (
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: Row
                  (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("£" + widget.product.price.toStringAsFixed(2)) ,Text(widget.product.category)]
                  )
                ),
                Container
                (
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Row
                  (
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: "btn1",
                        child: new Icon(IconData(0xe15b, fontFamily: 'MaterialIcons'), color: Colors.black,),
                        backgroundColor: Colors.white,
                        onPressed: () 
                        {
                          setState(() 
                          {
                            count = max(1, count - 1);
                          });
                        }
                      ),
                      Text(
                        count.toString(),
                        style: TextStyle
                        (
                          fontSize: 24
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: "btn2",
                        child: new Icon(Icons.add, color: Colors.black,),
                        backgroundColor: Colors.white,
                        onPressed: () 
                        {
                          setState(() 
                          {
                            count = count + 1;
                          });
                        }
                      ),]
                  )
                ),
                RaisedButton
                (
                  onPressed: ()
                  {
                    widget.addToBasket(widget.product, count);
                    Navigator.pop(context);
                  },
                  child: Padding
                  (
                    padding: EdgeInsets.all(15),
                    child: Text("Add To Basket",
                      style: TextStyle(fontSize: 24),
                    )
                  ),
                )
              ]
            ),
          )
        )
    );    
  }
}