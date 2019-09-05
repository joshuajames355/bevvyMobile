import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/storeFrontHome.dart';
import 'package:bevvymobile/productGridView.dart';
import 'package:flutter/material.dart';

enum StorePage {home, category, search}

class StoreFront extends StatefulWidget {
  StoreFront({Key key}) : super(key: key)
  {
    productList = [
      Product(iconName: "jd.jpg",
        title: "Jack Daniels (70cl)",
        description: "Dunno, Guess I Should put a description here.",
        price: "£19.99",
        category: "Whiskey"),
      Product(iconName: "smirnoff.jpg",
        title: "Smirnoff (70cl)",
        description: "Dunno, Guess I Should put a description here.",
        price: "£18.99",
        category: "Vodka"),
      Product(iconName: "russianStandard.jpg",
        title: "Russian Standard (70cl)",
        description: "Dunno, Guess I Should put a description here.",
        price: "£17.99",
        category: "Vodka"),
      Product(iconName: "strongbow.jpg",
        title: "Stronbow (70cl)",
        description: "Dunno, Guess I Should put a description here.",
        price: "£2.99",
        category: "Cider"),
      Product(iconName: "fosters.jpg",
        title: "Fosters (70cl)",
        description: "Dunno, Guess I Should put a description here.",
        price: "£3.99",
        category: "Beer"),
      Product(iconName: "echoFalls.jpg",
        title: "Echo Falls (70cl)",
        description: "Dunno, Guess I Should put a description here.",
        price: "£4.50",
        category: "Wine"),
      Product(iconName: "absolutVodka.jpg",
        title: "Absolut Vodka (70cl)",
        description: "Dunno, Guess I Should put a description here.",
        price: "£25.50",
        category: "Vodka"),
    ];

    categories = [];
    productListByCategory = Map();
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

  @override
  _StoreFrontState createState() => _StoreFrontState();
}

class _StoreFrontState extends State<StoreFront>{
  StorePage currentPage = StorePage.home;
  String currentCategory;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget page;

    if(currentPage == StorePage.home) page=StoreFrontHome(productListByCategory: widget.productListByCategory);
    if(currentPage == StorePage.category) page=ProductGridView(productList: widget.productListByCategory[currentCategory]);
    if(currentPage == StorePage.search) page=ProductGridView(productList: widget.productList.where((Product x)
    {
      return x.title.toLowerCase().contains(_controller.text.toLowerCase());
    }).toList());

    return Scaffold(
      appBar: AppBar(
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
              currentPage = StorePage.home;
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
            {},
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
          preferredSize: const Size.fromHeight(50),
          child: Align
          (
            alignment: Alignment.topCenter,
            child: Container
            (
              height: 50,
              child: ListView
              (
                scrollDirection: Axis.horizontal,
                children: widget.categories.map((String category)
                {
                    return Container
                    (
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: RaisedButton
                      (
                        child: Text(category),
                        onPressed: ()
                        {
                          setState(() 
                          {
                            currentCategory=category;
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
      ),
      body: page
    );
  }
}




