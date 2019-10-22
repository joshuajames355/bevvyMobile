import 'package:bevvymobile/homeAppBar.dart';
import 'package:bevvymobile/homeDrawer.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/storeFrontHome.dart';

class Home extends StatefulWidget {
  Home({Key key, this.productList}) : super(key: key) {
    categories = [];
    productList.forEach((Product x) {
      if(!categories.contains(x.category)) categories.add(x.category);
    });
  }

  List<Product> productList;
  List<String> categories;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context)  {
    return WillPopScope(
      onWillPop: () {
        return Future.value(scaffoldKey.currentState.isDrawerOpen);
      },
      child: Scaffold (
        key: scaffoldKey,
        appBar: HomeAppBar(productList: widget.productList,),
        body: StoreFrontHome (
          categories: widget.categories, 
        ),
        floatingActionButton: FloatingActionButton (
          child: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
          onPressed: () {
            Navigator.pushNamed(context, "/basket");
          },
        ),
        drawer: HomeDrawer()
      ),
    ); 
  }
}