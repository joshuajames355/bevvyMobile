import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

final double imageSize = 120;
final double largeImageSize = 250;

class Product
{
  final String title;
  final String description;
  final String iconName;
  final double price;
  final String category;
  final String size;
  final String priceCategory;

  final Widget icon;
  final Widget iconLarge;

  //Loads Image from file
  Product({this.title, this.description, this.price, this.category, this.iconName, this.size, this.priceCategory}) : icon = Image(
      image: AssetImage("images/" + iconName),
      width: imageSize,
      height: imageSize) ,iconLarge = Image(image: AssetImage("images/" + iconName),

      width: largeImageSize,
      height: largeImageSize);


  Product.fromNet({this.title, this.description, this.price, this.category, this.iconName, this.size, this.priceCategory, String apiBaseUrl}) : icon = CachedNetworkImage(
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