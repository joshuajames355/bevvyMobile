import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/checkout.dart';
import 'package:bevvymobile/firebase.dart';
import 'package:bevvymobile/home.dart';
import 'package:bevvymobile/login.dart';
import 'package:bevvymobile/orderScreen.dart';
import 'package:bevvymobile/transitions.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/productScreen.dart';
import 'package:bevvymobile/accountDetails.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  backgroundColor: Color(0xFFF2C1A4),//E26D25
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
  backgroundColor: Color(0xFFFFA796),
);

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  final Firestore store = Firestore();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{
  Map<Product, int> checkoutData; //Products and quantities.
  List<Order> orders;
  String location = "Current Location";
  FirebaseUser user;
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  initState()
  {
    super.initState();
    checkoutData = Map<Product, int>();
    orders = List<Order>();

    //Used to ensure persistance.
    auth.currentUser().then((FirebaseUser newUser)
    {
      setState(() {
       user=newUser; 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bevvy',
      theme: theme2,
      navigatorKey: navKey,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      routes: 
      {
        "/" : (context) => StreamBuilder
        (
          stream: widget.store.collection("inventory").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
          {
            if(!snapshot.hasData)
            {
              return Container
              (
                color: Theme.of(context).backgroundColor,
                width: double.infinity,
                height: double.infinity,
                child: Align
                (
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              );
            }
            return Home
            (
              productList: snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data)).toList(),
              orders: orders,
              location: location,
              onSetLocation: setLocation,
              user: user,
            );
          }
        )
      },
      onGenerateRoute: (RouteSettings settings)
      {
        if(settings.name == "/login")
        {
          return SlideLeftRoute(          
            page: LoginPage
            (
              onLogin: onLogin,
            ),
          );
        }
        else if(settings.name == "/accountDetails")
        {
          return SlideLeftRoute(          
            page: AccountDetails
            (
              user: user,
              onLogout: onLogout,
            ),    
          );
        }
        else if(settings.name == "/basket")
        {
          return ExpandRoute(          
            page: Basket
            (
              checkoutData: checkoutData,
              removeFromBasket: removeFromBasket,
            ),
          );
        }
        else if (settings.name == "/checkout")
        {
          return SlideLeftRoute
          (
            page: Checkout
            (
              onAddOrder: addOrder,
              checkoutData: checkoutData,
            ), 
          );   
        }
        else if(settings.name == "/product")
        {
          final Product args = settings.arguments;

          return ExpandRoute
          (
            page: ProductScreen
            (
              product: args, 
              addToBasket: addToBasket,
            )
          );  
        }
        else if(settings.name == "/order")
        {
          final Order args = settings.arguments;

          return ExpandRoute
          (
            page: OrderScreen
            (
              order: args,
            )
          );  
        }
      },
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
      checkoutData = Map<Product, int>();
    });
  }

  setLocation(String newLocation)
  {
    setState(() {
     location=newLocation; 
    });
  }

  onLogin(FirebaseUser newUser)
  {
    setState(() {
      user=newUser;
    });
    navKey.currentState.popUntil(ModalRoute.withName("/"));
    showDialog(context: navKey.currentState.overlay.context, builder: (context) => AlertDialog(title: Text("Success"), content: Text("You are now logged in.")));
  }

  onLogout()
  {
    setState(() {
      user=null;
    });
  }
}

void main() => runApp(App());