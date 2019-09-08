import 'package:bevvymobile/home.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key)
  {
    productList = [
      Product(iconName: "jd.jpg",
        title: "Jack Daniels (70cl)",
        description: "Dunno, Guess I Should put a description here. Lets just quickly make it long enough to wrap. This will probably make it long enough.",
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
  }

  List<Product> productList;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{
  Map<Product, int> checkoutData; //Products and quantities.

  @override
  initState()
  {
    super.initState();
    checkoutData = Map<Product, int>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bevvy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: 
      {
        "/" : (context) => Home
          (
            addToBasket: addToBasket,
            removeFromBasket: removeFromBasket,
            productList: widget.productList,
            checkoutData: checkoutData,
          )
      }
    );
  }

  addToBasket(Product product, int quantity)
  {
    setState(() {
      if(checkoutData.containsKey(product))
      {
        checkoutData[product] += quantity;
      }
      else
      {
        checkoutData[product] = quantity;
      }
    });
  }

  removeFromBasket(Product product)
  {
    setState(() {
      checkoutData.remove(product);
    });
  }
}

void main() => runApp(App());