import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

final double imageSize = 120;
final double largeImageSize = 250;

class Product
{
  final String title;
  final String description;
  final double price;
  final String category;
  final String size;
  final String priceCategory;

  final Widget icon;
  final Widget iconLarge;

  //Loads Image from file
  Product({this.title, this.description, this.price, this.category, iconName, this.size, this.priceCategory}) : icon = Image(
      image: AssetImage("images/" + iconName),
      width: imageSize,
      height: imageSize) ,iconLarge = Image(image: AssetImage("images/" + iconName),

      width: largeImageSize,
      height: largeImageSize);


  Product.fromFireStore({Map<String, dynamic> data}) : 
    icon = CachedNetworkImage
    (
      imageUrl: data["images"] is Map ? (data["images"]["thumbnail"] ?? "") : "", 
      placeholder: (context, url) => Align(
        alignment: Alignment.center,
        child: Container
        (
          child: CircularProgressIndicator(),
          height: largeImageSize,
        )
      ),
      width: imageSize,
      height: imageSize,
    ), 
    iconLarge = CachedNetworkImage
    (
      imageUrl: getLargeUrl(data) ?? (data["images"] is Map ? (data["images"]["thumbnail"] ?? "") : ""), //Fallbacks to thumbnail if no large url
      placeholder: (context, url) => Align(
        alignment: Alignment.center,
        child: Container
        (
          child: CircularProgressIndicator(),
          height: largeImageSize,
        )
      ),
      width: largeImageSize,
      height: largeImageSize,  
    ),
      title = data["name"] ?? "",
      price = double.parse(data["price"] ?? "0")/100,
      description = data["description"] ?? "",
      size = (data["size"] is Map ? (data["size"]["magnitude"] ?? "" ) + (data["size"]["unit"] ?? "" ): ""),
      priceCategory = "\$\$",
      category = data["category"] ?? "None"
    ;    
}

String getLargeUrl(Map<String, dynamic> data)
{
  try
  {
    var large_array = data["images"]["large_array"];
    if (large_array is String)
    {
      return large_array;
    }
    else if(large_array is List)
    {
      return large_array[0];
    }
    else
    {
      return null;
    }
  }
  catch (error)
  {
    return null;
  }
}