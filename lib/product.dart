import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "dart:math";

final double imageSize = 120;
final double largeImageSize = 250;

class Product
{
  final String title;
  final String description;
  final String iconName;
  final String price;
  final String category;

  final Widget icon;
  final Widget iconLarge;

  //Loads Image from file
  Product({this.title, this.description, this.price, this.category, this.iconName}) : icon = Image(
      image: AssetImage("images/" + iconName),
      width: imageSize,
      height: imageSize) ,iconLarge = Image(image: AssetImage("images/" + iconName),

      width: largeImageSize,
      height: largeImageSize);


  Product.fromNet({this.title, this.description, this.price, this.category, this.iconName, String apiBaseUrl}) : icon = CachedNetworkImage(
      imageUrl: apiBaseUrl + "/images/" + iconName, //Todo: Actually link to backend
      placeholder: (context, url) => CircularProgressIndicator(),
      width: imageSize,
      height: imageSize,
    ), iconLarge = CachedNetworkImage(
      imageUrl: apiBaseUrl + "/images/" + iconName, //Todo: Actually link to backend
      placeholder: (context, url) => CircularProgressIndicator(),
      width: largeImageSize,
      height: largeImageSize,  
    );
}

//Displayed in the main list views
class ProductWidget extends StatelessWidget
{
  const ProductWidget({ Key key, this.product}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Align(
    alignment: Alignment.topLeft,
    child: 
      FlatButton
      (
        onPressed: ()
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductWidgetFullScreen(product: product,)));
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

class ProductWidgetFullScreen extends StatefulWidget
{
  const ProductWidgetFullScreen({ Key key, this.product}) : super(key: key);

  final Product product;

  @override
  _ProductWidgetFullScreenState createState() => _ProductWidgetFullScreenState();
}

class _ProductWidgetFullScreenState extends State<ProductWidgetFullScreen>{
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