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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

int accentColour = 0XFF91FFF8;
Map<int, Color> accentColorPalette = 
{
  50: Color(accentColour),
  100: Color(accentColour),
  200: Color(accentColour),
  300: Color(accentColour),
  400: Color(accentColour),
  500: Color(accentColour),
  600: Color(accentColour),
  700: Color(accentColour),
  800: Color(accentColour),
  900: Color(accentColour),
};

int primaryColour = 0XFFFFA552;
Map<int, Color> primaryColourPalette = 
{
  50: Color(primaryColour),
  100: Color(primaryColour),
  200: Color(primaryColour),
  300: Color(primaryColour),
  400: Color(primaryColour),
  500: Color(primaryColour),
  600: Color(primaryColour),
  700: Color(primaryColour),
  800: Color(primaryColour),
  900: Color(primaryColour),
};

ThemeData darkTheme = ThemeData
(
  brightness: Brightness.dark,
  buttonColor: Color(0XFFFFA552),
  accentColor: MaterialColor(accentColour, accentColorPalette),

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
    auth.currentUser().then(handleAuthStateChange);

    auth.onAuthStateChanged.listen(handleAuthStateChange);
  }

  handleAuthStateChange(FirebaseUser updatedUser)
  async {
    setState(() {
      user=updatedUser; 
    });
    if (updatedUser == null) {
      // Logout
      navKey.currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } else {
      Crashlytics.instance.setUserIdentifier(updatedUser.uid);

      var userDocumentRef = Firestore.instance.collection('users').document(updatedUser.uid);
      var ds = await userDocumentRef.get();
      if (ds.exists) {
        // User document exists, now to change onboarding status
        if (ds.data['onboardingStatus'] == 'new_user') {
          navKey.currentState.pushReplacementNamed("/createAccount");
        } else if (ds.data['onboardingStatus'] == 'onboarded_user') {
          // Proceed to home
          navKey.currentState.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        } else {
          // Handle error
        }
      } else {
        // User document does not exist, create one
        userDocumentRef.setData({
          'onboardingStatus': 'new_user',
          'roles': ['customer']
        }).then((_) {
          handleAuthStateChange(updatedUser);
        }).catchError((e) {
          print("Error setting user's initial account document. %{e.error}");
          return -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jovi',
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
              return  Home
              (
                productList: snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data)).toList(),
                orders: orders,
                location: location,
                onSetLocation: setLocation,
                user: user,                
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
            page: (BuildContext context) => CreateAccount(user: user, handleAuthStateChangeFunc: handleAuthStateChange,)
          );
        }
        else if(settings.name == "/accountDetails")
        {
          return SlideLeftRoute
          (          
            page: (BuildContext context) => AccountDetails
            (
              user: user,
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
      bool foundItem = false;
      checkoutData = checkoutData.map((Product index, int value)
      {
        if(index.id == product.id) 
        {
          foundItem = true;
          return MapEntry(product, value + quantity);
        }
        return MapEntry(index, value);
      });
      if(!foundItem) checkoutData[product] = quantity;
    });
  }

  removeFromBasket(String productID)
  {
    setState(() {
      checkoutData.removeWhere((Product product, int quantity) => product.id == productID);
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

void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(App());
}
