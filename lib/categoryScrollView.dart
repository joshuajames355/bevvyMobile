import 'package:bevvymobile/categoryView.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

//Displays all products divided by category in a PageView
class CategoryScrollView extends StatefulWidget
{
  const CategoryScrollView({ Key key, this.productList, this.initialCategory}) : super(key: key);

  final List<Product> productList;
  final String initialCategory;

  @override
  _CategoryScrollViewState createState() => _CategoryScrollViewState();
}

class _CategoryScrollViewState extends State<CategoryScrollView>
{
  PageController _pageController;
  List<String> categories = [];
  Map<String, List<Product>> productListByCategory;

  @override
  void initState() {
    productListByCategory = Map<String, List<Product>>();
    widget.productList.forEach((Product x)
    {
      if(!categories.contains(x.category)) categories.add(x.category);
      if(!productListByCategory.containsKey(x.category))
      {
        productListByCategory[x.category] = [x];
      }
      else
      {
        productListByCategory[x.category].add(x);
      }
    });
    _pageController = PageController(initialPage: categories.indexOf(widget.initialCategory));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar
      (
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView
      (
        controller: _pageController,
        children: categories.map((String x)
        {
          return CategoryView
          (
            productList: productListByCategory[x],   
            categories: categories,
            currentCategory: categories.indexOf(x),
          );
        }).toList()
      ),
    );
  }
}