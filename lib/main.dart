import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/checkout.dart';
import 'package:bevvymobile/createAccount.dart';
import 'package:bevvymobile/createAccountSMS.dart';
import 'package:bevvymobile/globals.dart';
import 'package:bevvymobile/home.dart';
import 'package:bevvymobile/orderScreen.dart';
import 'package:bevvymobile/transitions.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/productScreen.dart';
import 'package:bevvymobile/accountDetails.dart';
import 'package:bevvymobile/splashScreen.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

int primaryColour = 0xFF3c4245;
Map<int, Color> colorPalette = 
{
  50: Color(0xFF5f6769),
  100: Color(0xFF5f6769),
  200: Color(0xFF5f6769),
  300: Color(primaryColour),
  400: Color(primaryColour),
  500: Color(primaryColour),
  600: Color(primaryColour),
  700: Color(0xFF3c4245),
  800: Color(0xFF3c4245),
  900: Color(0xFF3c4245),
};

ThemeData theme1 = ThemeData
(
  primarySwatch: MaterialColor(primaryColour, colorPalette),
  backgroundColor: Color(0xFF000000),
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

ThemeData darkTheme = ThemeData
(
  backgroundColor: Color(0XFF121212),
  brightness: Brightness.dark,
);

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  final Firestore store = Firestore();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{
  Map<Product, int> checkoutData; //Product ids and quantities.
  List<Order> orders;
  String location = "Current Location";
  FirebaseUser user;
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  Future<QuerySnapshot> catalogue;

  @override
  initState()
  {
    super.initState();
    checkoutData = Map<Product, int>();
    orders = List<Order>();

    catalogue = widget.store.collection("catalogue").where("available", isEqualTo: true).getDocuments();

    //Used to ensure persistance.
    auth.currentUser().then((FirebaseUser newUser)
    {
      setState(() {
       user=newUser; 
      });
      if(newUser != null)
      {
        navKey.currentState.pushNamed("/home");
      }
    });

    auth.onAuthStateChanged.listen((FirebaseUser newUser)
    {
      setState(() {
       user=newUser; 
      });
      if(newUser == null)
      {
        navKey.currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bevvy',
      theme: darkTheme,
      navigatorKey: navKey,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      onGenerateRoute: (RouteSettings settings)
      {
        if(settings.name == "/")
        {
          return MaterialPageRoute(builder: (context) => SplashScreen());
        }
        else if(settings.name == "/home")
        {
          return MaterialPageRoute(builder: (context) => FutureBuilder
          (
            future: catalogue,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
            {
              if(!snapshot.hasData)
              {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Container
                  (
                    color: Theme.of(context).backgroundColor,
                    width: double.infinity,
                    height: double.infinity,
                    child: Align
                    (
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  )
                );
              }
              return  WillPopScope(
                  onWillPop: () async => false,
                  child: Home
                (
                  productList: snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data)).toList(),
                  orders: orders,
                  location: location,
                  onSetLocation: setLocation,
                  user: user,
                )
              );
            }
          ));
        }
        else if(settings.name == "/createAccountSMS")
        {
          return SlideLeftRoute(          
            page: (BuildContext context) => CreateAccountSMS()
          );
        }
        else if(settings.name == "/createAccount")
        {
          return SlideLeftRoute(          
            page: (BuildContext context) => CreateAccount(user: settings.arguments,)
          );
        }
        else if(settings.name == "/accountDetails")
        {
          return SlideLeftRoute
          (          
            page: (BuildContext context) => AccountDetails
            (
              user: user,
              onLogout: onLogout,
              onUserChange: onUserChange,
            ),    
          );
        }
        else if(settings.name == "/basket")
        {
          return ExpandRoute(          
            page: (BuildContext context) => Basket
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
            page: (BuildContext context) => Checkout
            (
              onAddOrder: addOrder,
              checkoutData: checkoutData,
            ), 
          );   
        }
        else if(settings.name == "/product")
        {
          final Product args = settings.arguments;

          return MaterialPageRoute(builder: (context) => ProductScreen
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
            page: (BuildContext context) => OrderScreen
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
    navKey.currentState.pop();
    showDialog(context: navKey.currentState.overlay.context, builder: (context) => AlertDialog(title: Text("Success"), content: Text("You are now logged in.")));
  }

  onLogout()
  {
    showDialog(context: navKey.currentState.overlay.context, builder: (context) => AlertDialog(title: Text("Success"), content: Text("You are now logged out.")));
  }

  onUserChange()
  {
    auth.currentUser().then((FirebaseUser newUser)
    {
      setState(() {
       user=newUser; 
      });
    });  
  }
}

void main() => runApp(App());