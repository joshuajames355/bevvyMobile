import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//Renders a List of all products, seperated by categories.
class StoreFrontHome extends StatelessWidget
{
  const StoreFrontHome({ Key key, this.categories}) : super(key: key);

  final List<String> categories;

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
            onPressed: () => Navigator.pushNamed(context, "/category", arguments: x),
          )
        );
      }).toList()
    );
  }
}