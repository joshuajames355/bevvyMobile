import 'package:bevvymobile/categoryView.dart';
import 'package:bevvymobile/homeAppBar.dart';
import 'package:bevvymobile/homeDrawer.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      appBar: HomeAppBar(productList: widget.productList,),
      drawer: HomeDrawer(),
      floatingActionButton: FloatingActionButton
      (
        child: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
        onPressed: ()
        {
          Navigator.pushNamed(context, "/basket");
        },
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