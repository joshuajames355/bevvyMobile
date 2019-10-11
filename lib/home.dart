import 'package:bevvymobile/globals.dart';
import 'package:bevvymobile/order.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/storeFrontHome.dart';
import 'package:bevvymobile/productGridView.dart';
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
  final TextEditingController _controller = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  PageController  _pageController = PageController();
  PageController  _pageControllerSearch = PageController(initialPage: 1, keepPage: false);
  bool isSearchEnabled = false;

  @override
  Widget build(BuildContext context) 
  {
    return WillPopScope
    (
      onWillPop: ()
      {
        _pageController.animateToPage(0, duration: Duration(milliseconds: 600), curve: Curves.easeInOut);
        return Future.value(false);
      },
      child: Scaffold
      (
        key: scaffoldKey,
        appBar: buildAppBar(context),
        body: buildBody(context),
        floatingActionButton: FloatingActionButton
        (
          child: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
          onPressed: ()
          {
            Navigator.pushNamed(context, "/basket");
          },
        ),
        drawer: SizedBox
        (
          width: 200,
          child: Drawer
          (
            child: Column
            (
              children: 
              [
                DrawerHeader
                (
                  child: Image
                  (
                    height: 100,
                    width: 100,
                    image: AssetImage
                    (
                      'images/logo.png',
                    ),
                  ),
                ),
                ListTile
                (
                  title: Text("Home"),
                  trailing: Icon(IconData(59530, fontFamily: 'MaterialIcons')),
                  onTap: ()
                  {
                    if(!isSearchEnabled) _pageController.animateToPage(0, duration: Duration(milliseconds: 600), curve: Curves.easeInOut);
                    setState(() {
                      isSearchEnabled = false; 
                    });
                  },
                ),
                ListTile
                (
                  title: Text("My Account"),
                  trailing: Icon(IconData(59473, fontFamily: 'MaterialIcons')),
                  onTap: ()
                  {
                    Navigator.popAndPushNamed(context, "/accountDetails");
                  },
                ),
                Expanded(child: Container(),),
                ListTile
                (
                  title: Text("Log out"),
                  trailing: Icon(IconData(59513, fontFamily: 'MaterialIcons')),
                  onTap: ()
                  {
                    auth.signOut();
                  },
                ),
              ]
            ),
          ),
        ),
      ),
    ); 
  }

  Widget buildBody(BuildContext context)
  {
    if(isSearchEnabled)
    {
      //Starts animation on next frame.
      Future.delayed(Duration(milliseconds: 10)).then((_)
      {
        _pageControllerSearch.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
      });
      return PageView
      (
        controller: _pageControllerSearch,
        children: 
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
          ProductGridView(productList: widget.productList.where((Product x)
          {
            return x.title.toLowerCase().contains(_controller.text.toLowerCase());
          }).toList())
        ],
        onPageChanged: (int page)
        {
          if(page == 0)
          {
            setState(() {
              isSearchEnabled = false;
            });
          }
        },
      );      
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
      )
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

  AppBar buildAppBar(BuildContext context)
  {
    return AppBar
    (
      leading: FlatButton
      (
        child: Icon(IconData(58834, fontFamily: 'MaterialIcons')),
        onPressed: ()
        {
          scaffoldKey.currentState.openDrawer();
        },
        padding: EdgeInsets.all(2),
      ),
      title: TextField
      (
        decoration: InputDecoration
        (
          border: UnderlineInputBorder(),
          labelText: 'Search',
          icon: Icon
          (
            IconData(59574, fontFamily: 'MaterialIcons'),
            size: 30
          ),
        ),
        style: TextStyle
        (
          fontSize: 24,
        ),
        controller: _controller,
        onChanged: (String currentText) => showSearchResults(),
        onSubmitted: (String currentText) => showSearchResults(),
      ),
      actions: 
      [
        IconButton
        (
          onPressed: ()
          {
            
          },
          icon: Icon
          (
            IconData(57682, fontFamily: 'MaterialIcons'),
            size: 30
          ),
        )
      ],
    );
  }

  showSearchResults()
  {
    setState(() {
     isSearchEnabled = true; 
    });
  }
}