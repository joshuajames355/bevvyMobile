import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bevvymobile/login.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/StoreFrontHome.dart';
import 'package:bevvymobile/productGridView.dart';
import 'package:bevvymobile/basket.dart';

typedef void RemoveFromBasketFunc(Product product);
typedef void AddToBasketFunc(Product product, int quantity);

enum StorePage {home, category, search}

class Home extends StatefulWidget {
  Home({Key key, this.productList, this.checkoutData, this.removeFromBasket, this.addToBasket}) : super(key: key)
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

  List<Product> productList;
  List<String> categories;
  Map<String, List<Product>> productListByCategory;
  final Map<Product, int> checkoutData;
  RemoveFromBasketFunc removeFromBasket;
  AddToBasketFunc addToBasket;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();
  StorePage currentPage = StorePage.home;
  int currentCategory;

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: buildAppBar(context),
      body: buildBody(context),
      floatingActionButton: FloatingActionButton
      (
        child: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
        onPressed: ()
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Basket(checkoutData: widget.checkoutData, removeFromBasket: widget.removeFromBasket,)));
        },
      ),
    ); 
  }

  Widget buildBody(BuildContext context)
  {
    if(currentPage == StorePage.home)
    {
      return GestureDetector
      (
        child: Container
        (
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child:StoreFrontHome
          (
            productListByCategory: widget.productListByCategory,
            onSelectCategory: (String category)
            {
              setState(() {
                currentCategory=widget.categories.indexOf(category); 
                currentPage=StorePage.category;
              });
            },
            checkoutData: widget.checkoutData,
            addToBasket: widget.addToBasket
          ),
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
        child: Container
        (
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child:ProductGridView(productList: widget.productList.where((Product x)
          {
            return x.title.toLowerCase().contains(_controller.text.toLowerCase());
          }).toList(),
          checkoutData: widget.checkoutData,
            addToBasket: widget.addToBasket),
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
        child: Container
        (
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child: GestureDetector
          (
            child: ProductGridView(productList: widget.productListByCategory[widget.categories[currentCategory]], checkoutData: widget.checkoutData,  addToBasket: widget.addToBasket),
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
          child: Image(
            image: AssetImage
              (
                'images/icon.jpg',
              ),
          ),
          onPressed: ()
          {
            setState(() {
              currentPage=StorePage.home;
            });
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
              color: Colors.black,
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: Icon
            (
              IconData(59475, fontFamily: 'MaterialIcons'),
              color: Colors.black,
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