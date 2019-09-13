import 'package:bevvymobile/home.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter/material.dart';


int primaryColour = 0XFFB14AED;
Map<int, Color> colorPalette = 
{
  50: Color(0xFFC874D9),
  100: Color(0xFFC874D9),
  200: Color(0xFFC874D9),
  300: Color(primaryColour),
  400: Color(primaryColour),
  500: Color(primaryColour),
  600: Color(primaryColour),
  700: Color(0xFF1B1F3B),
  800: Color(0xFF1B1F3B),
  900: Color(0xFF1B1F3B),
};

ThemeData theme1 = ThemeData
(
  primarySwatch: MaterialColor(primaryColour, colorPalette),
  backgroundColor: Color(0xFFE1BBC9),
);


int primaryColour2 = 0XFFE23425;
Map<int, Color> colorPalette2 = 
{
  50: Color(0xFFE24725),
  100: Color(0xFFE24725),
  200: Color(0xFFE24725),
  300: Color(primaryColour2),
  400: Color(primaryColour2),
  500: Color(primaryColour2),
  600: Color(primaryColour2),
  700: Color(0xFFE22525),
  800: Color(0xFFE22525),
  900: Color(0xFFE22525),
};

ThemeData theme2 = ThemeData
(
  primarySwatch: MaterialColor(primaryColour2, colorPalette2),
  backgroundColor: Color(0x2FE26D25),//E26D25
);

int primaryColour3 = 0XFF910B3E;
Map<int, Color> colorPalette3 = 
{
  50: Color(0xFFC70039),
  100: Color(0xFFC70039),
  200: Color(0xFFC70039),
  300: Color(primaryColour3),
  400: Color(primaryColour3),
  500: Color(primaryColour3),
  600: Color(primaryColour3),
  700: Color(0xFF571847),
  800: Color(0xFF571847),
  900: Color(0xFF571847),
};

ThemeData theme3 = ThemeData
(
  primarySwatch: MaterialColor(primaryColour3, colorPalette3),
  backgroundColor: Color(0x3FFF5633),
);

class App extends StatefulWidget {
  App({Key key}) : super(key: key)
  {
    productList = [
      Product(iconName: "jd.jpg",
        title: "Jack Daniels",
        size: "70cl",
        priceCategory: "££",
        description: "Dunno, Guess I Should put a description here. Lets just quickly make it long enough to wrap. This will probably make it long enough.",
        price: 19.99,
        category: "Whiskey"),
      Product(iconName: "smirnoff.jpg",
        title: "Smirnoff",
        size: "70cl",
        priceCategory: "££",
        description: "Dunno, Guess I Should put a description here.",
        price: 18.99,
        category: "Vodka"),
      Product(iconName: "russianStandard.jpg",
        title: "Russian Standard",
        size: "70cl",
        priceCategory: "££",
        description: "Dunno, Guess I Should put a description here.",
        price: 17.99,
        category: "Vodka"),
      Product(iconName: "strongbow.jpg",
        title: "Strongbow",
        size: "440ml",
        priceCategory: "£",
        description: "Dunno, Guess I Should put a description here.",
        price: 2.99,
        category: "Cider"),
      Product(iconName: "fosters.jpg",
        title: "Fosters",
        size: "330ml",
        priceCategory: "£",
        description: "Dunno, Guess I Should put a description here.",
        price: 3.99,
        category: "Beer"),
      Product(iconName: "echoFalls.jpg",
        title: "Echo Falls",
        size: "500ml",
        priceCategory: "£",
        description: "Dunno, Guess I Should put a description here.",
        price: 4.50,
        category: "Wine"),
      Product(iconName: "absolutVodka.jpg",
        title: "Absolut Vodka",
        size: "1L",
        priceCategory: "£££",
        description: "Dunno, Guess I Should put a description here.",
        price: 25.50,
        category: "Vodka"),
    ];
  }

  List<Product> productList;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{
  Map<Product, int> checkoutData; //Products and quantities.
  List<Order> orders;

  @override
  initState()
  {
    super.initState();
    checkoutData = Map<Product, int>();
    orders = List<Order>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bevvy',
      theme: theme2,
      routes: 
      {
        "/" : (context) => Home
          (
            addToBasket: addToBasket,
            removeFromBasket: removeFromBasket,
            productList: widget.productList,
            checkoutData: checkoutData,
            orders: orders,
            onAddOrder: addOrder,
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

  addOrder(Order order)
  {
    setState(() {
      orders.add(order);
    });
  }
}

void main() => runApp(App());