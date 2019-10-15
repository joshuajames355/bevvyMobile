import 'package:bevvymobile/globals.dart';
import 'package:bevvymobile/homeAppBar.dart';
import 'package:bevvymobile/order.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/storeFrontHome.dart';
import 'package:bevvymobile/categoryView.dart';

import 'package:firebase_auth/firebase_auth.dart';

typedef void RemoveFromBasketFunc(Product product);
typedef void AddOrder(Order order);
typedef void SetLocation(String newLocation);

enum StorePage {home, category, search}

class Home extends StatefulWidget {
  Home({Key key, this.productList, this.orders, this.location, this.onSetLocation, this.user}) : super(key: key)
  {
    categories = [];
    productListByCategory = Map<String, List<Product>>();
    productList.forEach((Product x)
    {
      if(!categories.contains(x.category))
      {
        categories.add(x.category);
      }
      if(productListByCategory.containsKey(x.category))
      {
        productListByCategory[x.category].add(x);
      }
      else
      {
        productListByCategory[x.category] = [x];
      }
    });
  }

  String location;
  List<Product> productList;
  List<String> categories;
  Map<String, List<Product>> productListByCategory;
  List<Order> orders;
  SetLocation onSetLocation;
  final FirebaseUser user;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  PageController  _pageController = PageController();
  bool goToFirstPage = false;

  @override
  Widget build(BuildContext context) 
  {
    return WillPopScope
    (
      onWillPop: ()
      {
        if(scaffoldKey.currentState.isDrawerOpen)
        {
          return Future.value(true);
        }
        setState(() {
          goToFirstPage = true;
        });

        return Future.value(false);
      },
      child: Scaffold
      (
        key: scaffoldKey,
        appBar: HomeAppBar(productList: widget.productList,),
        body: buildBody(context),
        floatingActionButton: FloatingActionButton
        (
          child: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
          onPressed: ()
          {
            Navigator.pushNamed(context, "/basket");
          },
        ),
        drawer: HomeDrawer()
      ),
    ); 

  Widget buildBody(BuildContext context)
  {
    if(goToFirstPage)
    {
      goToFirstPage = false;
      //Starts animation on next frame.
      Future.delayed(Duration(milliseconds: 10)).then((_)
      {
        _pageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
      });
    }

    List<Widget> pages = 
    [
      StoreFrontHome
      (
        categories: widget.categories,
        onSelectCategory: (String category)
        {
          if(widget.categories.contains(category))
          {
            setState(() {
              _pageController.animateToPage(widget.categories.indexOf(category) + 1, duration: Duration(milliseconds: 600), curve: Curves.easeInOut);
            });
          }
        },   
      ),      
    ];
    pages.addAll(widget.categories.map((String x)
    {
      return CategoryView
      (
        productList: widget.productListByCategory[x],   
        category: x,
      );
    }));

    return PageView
    (
      children: pages,
      controller: _pageController
    );
  }
}