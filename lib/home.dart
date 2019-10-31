import 'package:bevvymobile/homeAppBar.dart';
import 'package:bevvymobile/homeDrawer.dart';
import 'package:bevvymobile/homeNavBar.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/storeFrontHome.dart';

class Home extends StatefulWidget {
  Home({Key key, this.productList}) : super(key: key) {
    categories = [];
    productListByCategory = Map<String, List<Product>>();
    productList.forEach((Product x) {
      if(!categories.contains(x.category)) categories.add(x.category);
      if(productListByCategory.containsKey(x.category)) productListByCategory[x.category].add(x);
      else productListByCategory[x.category] = [x];
    });
  }

  List<Product> productList;
  List<String> categories;
  Map<String, List<Product>> productListByCategory;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> ScaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context)  {
    return WillPopScope(
      onWillPop: () {
        return Future.value(ScaffoldKey.currentState.isDrawerOpen);
      },
      child: Scaffold (
        key: ScaffoldKey,
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
        bottomNavigationBar: HomeNavBar(
          currentIndex: 0,
        ),
        body: StoreFrontHome (
          productListByCategory: widget.productListByCategory,
        ),
      ),
    ); 
  }
}