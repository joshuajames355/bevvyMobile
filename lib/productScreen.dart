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
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons')),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column
      (
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          productImage(widget.product, context),
          Padding
          (
            padding: EdgeInsets.all(12),
            child: Column
            (
              children: <Widget>
              [
                Text(widget.product.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.left,),
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 
                  [
                    Text(widget.product.category),
                    Text(widget.product.size),
                    Text(getAgeRestrictionMessage(widget.product)),
                  ]
                ),
              ]
            ),
          ),
          Expanded
          (
            child: Padding
            (
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: ListView(children: [Text(widget.product.description)])
            )
          ),
          Padding
          (
            padding: EdgeInsets.all(5),
            child: Row
            (
              children: <Widget>
              [
                Expanded
                (
                  child: Row
                  (
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: 
                    [
                      FloatingActionButton
                      (
                        heroTag: "btn1",
                        child: new Icon(IconData(0xe15b, fontFamily: 'MaterialIcons')),
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
                          fontSize: 18
                        ),
                      ),
                      FloatingActionButton
                      (
                        heroTag: "btn2",
                        child: new Icon(Icons.add),
                        onPressed: () 
                        {
                          setState(() 
                          {
                            count = count + 1;
                          });
                        }
                      ),  
                    ]
                  )
                ),
                Expanded
                (
                  child: RaisedButton
                  (
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(8.0)),
                    onPressed: ()
                    {
                      widget.addToBasket(widget.product, count);
                      Navigator.pop(context);
                    },
                    child: Padding
                    (
                      padding: EdgeInsets.all(15),
                      child: Container
                      (
                        width: double.infinity,
                        child: Center(child: Text("Add To Basket",
                          style: TextStyle(fontSize: 18)),
                        )
                      )
                    ),
                  )
                )
              ]
            )
          )
        ]
      ), 
    );    
  }
}

String getAgeRestrictionMessage(Product product)
{
  if(product.legalRestriction == "alcohol")
  {
    return "18+";
  }
  else
  {
    return "";
  }
}

Widget productImage(Product product, BuildContext context) => Hero
  (
    tag: product.id,
    child: Stack
    (
      children: 
      [
        Container
        (
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.width), //maintain aspect ratio of 1
          child: SizedBox
          (
            width: MediaQuery.of(context).size.width,
            child: FittedBox
            (
              child: product.iconLarge,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned
        (
          left: 15,
          bottom: 15,
          child: Container
          (
            width: 60,
            height: 60,
            decoration: BoxDecoration
            (
              color: Theme.of(context).buttonColor,
              boxShadow: 
              [
                BoxShadow
                (
                  color: Colors.red,
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(
                    1.5, // horizontal, move right 10
                    1.5, // vertical, move down 10
                  ),
                ),
              ],
              shape: BoxShape.circle
            ),
            child: Center
            (
              child: Text("£" + product.price.toStringAsFixed(2), style: TextStyle(color: Colors.white),),
            )
          )
        )
      ]
    ),
  );