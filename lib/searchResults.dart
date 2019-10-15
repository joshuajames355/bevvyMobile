import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/productGridView.dart';

//Renders a List of all products, seperated by categories.
class SearchResults extends StatelessWidget
{
  const SearchResults({ Key key, this.products}) : super(key: key);

  final List<Product> products;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text("Search Results"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons')),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: ProductGridView
      (
        productList: products,
      ),
    );
  }
}