import 'dart:math';

import 'package:bevvymobile/order.dart';
import 'package:flutter/material.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/StoreFrontHome.dart';
import 'package:bevvymobile/productGridView.dart';

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
  StorePage currentPage = StorePage.home;
  int currentCategory;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
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
      drawer: Drawer
      (
        child: ListView
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
              title: Center(child: Text("Home")),
              onTap: ()
              {
                setState(() {
                  currentPage=StorePage.home; 
                });
                Navigator.pop(context);
              },
            ),
            ListTile
            (
              title: Center(child: Text("My Account")),
              onTap: ()
              {
                Navigator.popAndPushNamed(context, "/accountDetails");
              },
            )
          ]
        ),
      ),
    ); 
  }

  Widget buildBody(BuildContext context)
  {
    if(currentPage == StorePage.home)
    {
      return GestureDetector
      (
        child: StoreFrontHome
          (
            productListByCategory: widget.productListByCategory,
            onSelectCategory: (String category)
            {
              if(widget.categories.contains(category))
              {
                setState(() {
                  currentCategory=widget.categories.indexOf(category); 
                  currentPage=StorePage.category;
                });
              }
            },
            orders: widget.orders,
        ),
        onHorizontalDragEnd: (DragEndDetails details)
          {
            if(details.velocity.pixelsPerSecond.dx < -150)
            {
              setState(() {
                currentCategory=0;
                currentPage=StorePage.category;
              });
            }
          }
          
      );
    }
    else if(currentPage == StorePage.search)
    {
      return WillPopScope
      (
        child: ProductGridView(productList: widget.productList.where((Product x)
          {
            return x.title.toLowerCase().contains(_controller.text.toLowerCase());
          }).toList()
        ),        
        onWillPop: () 
        {
          setState(() {
            currentPage=StorePage.home; 
          });
        }
      );
    }
    else
    {
      return WillPopScope(
        child: GestureDetector
        (
          child: ProductGridView
          (
            productList: widget.productListByCategory[widget.categories[currentCategory]],  
          ),
          onHorizontalDragEnd: (DragEndDetails details)
          {
            if(details.velocity.pixelsPerSecond.dx > 150)
            {
              setState(() {
                if(currentCategory==0)
                {
                  currentPage=StorePage.home;
                }
                else
                {
                  currentCategory--;
                }
              });
            }
            else if(details.velocity.pixelsPerSecond.dx < -150)
            {
              setState(() {
                currentCategory=min(currentCategory+1, widget.categories.length-1);
              });
            }
          },
        ),        
        onWillPop: () 
        {
          setState(() {
            currentPage=StorePage.home; 
          });
        }
      );
    }
  }

  AppBar buildAppBar(BuildContext context)
  {
    return AppBar(
        leading: FlatButton
          (
          child: Icon(IconData(58834, fontFamily: 'MaterialIcons')),
          onPressed: ()
          {
            scaffoldKey.currentState.openDrawer();
          },
          padding: EdgeInsets.all(2),
        ),
        title: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
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
          onChanged: (String currentText)
          {
            setState(() {
              currentPage=StorePage.search;
            });
          },
          onSubmitted: (String currentText)
          {
            setState(() {
              currentPage=StorePage.search;
            });
          },
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
        bottom: PreferredSize
        (
          preferredSize: const Size.fromHeight(60),
          child: Align
          (
            alignment: Alignment.topCenter,
            child: Container
            (
              height: 50,
              margin: EdgeInsets.all(4),
              child: ListView
              (
                scrollDirection: Axis.horizontal,
                children: widget.categories.map((String category)
                {
                    return Container
                    (
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: RaisedButton
                      (
                        child: Text(category),
                        color: Theme.of(context).backgroundColor,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(12))),
                        onPressed: ()
                        {
                          setState(() {
                            currentCategory=widget.categories.indexOf(category); 
                            currentPage=StorePage.category;
                          });
                        },
                      )
                    );
                }).toList()
              ),
            )
          )
        )
    );
  }
}