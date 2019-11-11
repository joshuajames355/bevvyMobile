import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/productWidgetSquare.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef void OnSelectCategory(String category);

//Renders a List of all products, seperated by categories.
class StoreFrontHome extends StatelessWidget
{
  const StoreFrontHome({ Key key, this.productListByCategory}) : super(key: key);

  final Map<String, List<Product>> productListByCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>
        [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/search"),
            icon: Icon(IconData(59574, fontFamily: 'MaterialIcons')),
          )
        ],
      ),
      body: ListView
      (
        children: joinElements(productListByCategory.keys.toList().map((String category)
        {
          return makeSection(category, productListByCategory[category].map((Product product) =>  ProductWidgetSquare(product: product,)).toList(), context);
        }).toList())
      )
    );
  }

  Widget makeSection(String title, List<Widget> content, BuildContext context)
  {
    return Container
    (
      child: Column
      (
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(title, style: TextStyle(fontSize: 20)),
                ),
                FlatButton(
                  onPressed: (){
                    Navigator.pushNamed(context, "/category", arguments: title);
                  },
                  child: Text("See All", style: TextStyle(color: Theme.of(context).accentColor))
                )
              ],
            )
          ),
          Container
          (
            height: 180,
            child: ListView
            (
              scrollDirection: Axis.horizontal,
              children: content
            ),
          )
        ],
      ),
    );
  }
}

List<Widget> joinElements(List<Widget> elements)
{
  if(elements.length == 0) return [];

  List<Widget> joinedElements = [elements[0]];
  for(int x = 1; x < elements.length; x++) 
  {
    joinedElements.addAll([Divider(height: 30, thickness: 2,), elements[x]]);
  }
  return joinedElements;
}