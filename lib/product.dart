import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

final double imageSize = 120;
final double largeImageSize = 250;

class Product
{
  final String id;
  final String title;
  final String description;
  final int price;
  final String category;
  final String size;
  final String legalRestriction;

  final Widget icon;
  final Widget iconLarge;

  double get priceAsDouble {
    return price.toDouble() / 100;
  }

  String get priceString {
    return "£" + priceAsDouble.toStringAsFixed(2);
  }

  //Loads Image from file
  Product({this.id, this.title, this.description, this.price, this.category, iconName, this.size}) : icon = Image(
      image: AssetImage("images/" + iconName),
      width: imageSize,
      height: imageSize) ,iconLarge = Image(image: AssetImage("images/" + iconName),

      width: largeImageSize,
      height: largeImageSize,), legalRestriction = "";


  Product.fromFireStore({Map<String, dynamic> data, this.id}) : 
    icon = CachedNetworkImage
    (
      imageUrl: data["images"] is Map ? (data["images"]["thumbnail"] != null && data["images"]["thumbnail"] is String ? data["images"]["thumbnail"] : "") : "", 
      placeholder: (context, url) => Align(
        alignment: Alignment.center,
        child: Container
        (
          decoration: BoxDecoration(color: Colors.black),
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
          decoration: BoxDecoration(color: Colors.black),
          height: largeImageSize,
        )
      ),
      width: largeImageSize,
      height: largeImageSize,  
    ),
      title = (data["name"] != null && data["name"] is String) ? data["name"] : "",
      price = (data["price"] != null && data["price"] is int ? data["price"] : 0),
      description = (data["description"] != null && data["description"] is String) ? data["description"] : "",
      size = (data["size"] is Map ? ((data["size"]["magnitude"] != null && (data["size"]["magnitude"] is int || data["size"]["magnitude"] is double) ) ? data["size"]["magnitude"] : 0 ).toString() + ((data["size"]["unit"] != null && data["size"]["unit"] is String) ? data["size"]["unit"] : "" ): ""),
      category = (data["category"] != null && data["category"] is String) ? data["category"]  : "None",
      legalRestriction = (data["legal_restriction"] != null && data["legal_restriction"] is String) ? data["legal_restriction"]  : ""
    ;    
}

String getLargeUrl(Map<String, dynamic> data)
{
  try
  {
    var largeArray = data["images"]["large_array"];
    if (largeArray is String)
    {
      return largeArray;
    }
    else if(largeArray is List && largeArray.length > 0 && largeArray[0] is String)
    {
      return largeArray[0];
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