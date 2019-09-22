import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";
import "dart:math";

typedef void AddToBasketFunc(Product product, int quantity);

class ProductScreen extends StatefulWidget
{
  const ProductScreen({ Key key, this.product, this.addToBasket}) : super(key: key);

  final Product product;
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
      body: Container
      (
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: Padding
        (
          padding: EdgeInsets.all(20),
          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              widget.product.iconLarge,
              Expanded
              (
                child: Padding
                (
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: ListView(children: [Text(widget.product.description)])
                )
              ),
              Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("£" + widget.product.price.toStringAsFixed(2)) ,Text(widget.product.category)]
              ),
              Padding
              (
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: "btn1",
                      child: new Icon(IconData(0xe15b, fontFamily: 'MaterialIcons'), color: Colors.black,),
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
                  color: Theme.of(context).primaryColor,
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