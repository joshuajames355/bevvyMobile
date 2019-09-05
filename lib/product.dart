import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

final double imageSize = 120;

class Product
{
  final String title;
  final String description;
  final String iconName;
  final String price;
  final String category;

  final Widget icon;

  //Loads Image from file
  Product({this.title, this.description, this.price, this.category, this.iconName}) : icon = Image(
      image: AssetImage("images/" + iconName),
      width: imageSize,
      height: imageSize,
      );


  Product.fromNet({this.title, this.description, this.price, this.category, this.iconName, String apiBaseUrl}) : icon = CachedNetworkImage(
      imageUrl: apiBaseUrl + "/images/" + iconName, //Todo: Actually link to backend
      placeholder: (context, url) => CircularProgressIndicator(),
      width: imageSize,
      height: imageSize,
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
      Container
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
                style: TextStyle
                (
                  fontSize: 18
                ),
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
    );
  }
}