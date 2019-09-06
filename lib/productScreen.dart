import 'package:flutter/material.dart';
import "product.dart";
import "dart:math";

class ProductScreen extends StatefulWidget
{
  const ProductScreen({ Key key, this.product}) : super(key: key);

  final Product product;

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
                    children: [Text(widget.product.price)]
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
                    //Todo basket
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