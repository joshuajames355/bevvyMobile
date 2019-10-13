import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef void OnSelectCategory(String category);

//Renders a List of all products, seperated by categories.
class StoreFrontHome extends StatelessWidget
{
  const StoreFrontHome({ Key key, this.categories, this.onSelectCategory}) : super(key: key);

  final List<String> categories;
  final OnSelectCategory onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return GridView.count
    (
      crossAxisCount: 2,
      padding: EdgeInsets.symmetric(vertical: 10),
      children: categories.map((String x) 
      {
        return Card
        (
          child: FlatButton
          (
            child: Center(child: Text(x)),
            onPressed: () => onSelectCategory(x),
          )
        );
      }).toList()
    );
  }
}