import 'dart:async';
import 'dart:io';

import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/categoryScrollView.dart';
import 'package:bevvymobile/checkout.dart';
import 'package:bevvymobile/createAccount.dart';
import 'package:bevvymobile/createAccountSMS.dart';
import 'package:bevvymobile/globals.dart';
import 'package:bevvymobile/home.dart';
import 'package:bevvymobile/orderScreen.dart';
import 'package:bevvymobile/searchResults.dart';
import 'package:bevvymobile/transitions.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/paymentMethods.dart';
import 'package:bevvymobile/productScreen.dart';
import 'package:bevvymobile/accountDetails.dart';
import 'package:bevvymobile/splashScreen.dart';
import 'package:bevvymobile/checkoutLocation.dart';
import 'package:bevvymobile/config.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

int accentColour = 0XFF91FFF8;
Map<int, Color> accentColorPalette = {
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
Map<int, Color> primaryColourPalette = {
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

ThemeData darkTheme = ThemeData(
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

class _AppState extends State<App> {
  Map<Product, int> checkoutData; //Product ids and quantities.
  List<Order> orders;
  FirebaseUser user;
  Stream<DocumentSnapshot> userData;
  final GlobalKey<NavigatorState> navKey = new GlobalKey<NavigatorState>();
  Future<QuerySnapshot> catalogue;
  Stream<QuerySnapshot> paymentMethodsStream;
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod selectedMethod;

  @override
  initState() {
    super.initState();
    checkoutData = Map<Product, int>();
    orders = List<Order>();

    catalogue = widget.store.collection("catalogue").where("available", isEqualTo: true).getDocuments();

    //Used to ensure persistance.
    auth.currentUser().then(handleAuthStateChange);
    auth.onAuthStateChanged.listen(handleAuthStateChange);

    new Future.delayed(Duration.zero, () {
      var config = AppConfig.of(context);
      StripePayment.setOptions(
        StripeOptions(publishableKey: config.stripePublishableKey,
                      merchantId: config.stripeMerchantId,
                      androidPayMode: config.stripeAndroidPayMode));
    });
  }

  handleAuthStateChange(FirebaseUser updatedUser) async {
    setState(() {
      user = updatedUser; 
    });
    if (updatedUser == null) {
      // Logout
      navKey.currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } else {
      Crashlytics.instance.setUserIdentifier(updatedUser.uid);

      var userDocumentRef = Firestore.instance.collection('users').document(updatedUser.uid);
      userData = userDocumentRef.snapshots();
      var ds = await userData.first;

      paymentMethodsStream = Firestore.instance.collection('users').document(updatedUser.uid).collection('payment_methods').snapshots();
      paymentMethodsStream.handleError((error) {
        //Crashlytics.
      });
      paymentMethodsStream.listen((QuerySnapshot query) async {
        paymentMethods = query.documents.map((DocumentSnapshot x ) => PaymentMethod.fromJson(x.data["asJSON"])).toList();

        if (selectedMethod == null && paymentMethods.length > 0) {
          setState(() => selectedMethod = paymentMethods[0]);
        } else if (selectedMethod == null && paymentMethods.length == 0) {
          try {
            bool canMakeNativePayments = await StripePayment.canMakeNativePayPayments([]);
            if (canMakeNativePayments) {
              setState(() => selectedMethod = PaymentMethod(type: (Platform.isIOS ? 'applepay' : 'googlepay')));
            }
          } catch (e) {
            print(e);
          }
        }
      });

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
      onGenerateRoute: (RouteSettings settings) {
        if(settings.name == "/") {
          return MaterialPageRoute(builder: (context) => SplashScreen());
        }
        else if(settings.name == "/home") {
          return MaterialPageRoute(builder: (context) => FutureBuilder(
            future: catalogue,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(!snapshot.hasData) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Container(
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
              return  Home(
                productList: snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data)).toList(),           
              );
            }
          ));
        }
        else if(settings.name == "/createAccountSMS") {
          return SlideLeftRoute(          
            page: (BuildContext context) => CreateAccountSMS()
          );
        }
        else if(settings.name == "/createAccount") {
          return SlideLeftRoute(          
            page: (BuildContext context) => CreateAccount(user: user, handleAuthStateChangeFunc: handleAuthStateChange,)
          );
        }
        else if(settings.name == "/accountDetails") {
          return MaterialPageRoute(builder: (context) => StreamBuilder(
            stream: userData,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if(!snapshot.hasData) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    width: double.infinity,
                    height: double.infinity,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  )
                );
              }
              return  AccountDetails(
                user: user,
                onUserChange: onUserChange,
                userDocument: snapshot.data,
              );
            }
          ));
        }
        else if(settings.name == "/basket") {
          return ExpandRoute(          
            page: (BuildContext context) => Basket(
              checkoutData: checkoutData,
              removeFromBasket: removeFromBasket,
            ),
          );
        }
        else if (settings.name == "/checkout") {
          return SlideLeftRoute(
            page: (BuildContext context) => Checkout(
              checkoutData: checkoutData,
              location: settings.arguments,
              paymentMethod: selectedMethod,
            ), 
          );   
        }
        else if (settings.name == "/checkoutLocation") {
          return SlideLeftRoute(
            page: (BuildContext context) => CheckoutLocation(), 
          );   
        }
        else if(settings.name == "/product")
        {
          final Product args = settings.arguments;

          return MaterialPageRoute(builder: (context) => ProductScreen(
              product: args, 
              addToBasket: addToBasket,
            )
          );
        }
        else if(settings.name == "/paymentMethods") {
          return MaterialPageRoute(builder: (context) => PaymentMethods(
            user: user,
            paymentMethods: paymentMethods,      
            selectedMethod: selectedMethod,
            onChangeSelectedMethod: (PaymentMethod method) {
              setState(() {
                selectedMethod = method;
              });
            },  
          )); 
        }
        else if(settings.name == "/order") {
          final Order args = settings.arguments;

          return ExpandRoute(
            page: (BuildContext context) => OrderScreen
            (
              order: args,
            )
          );  
        }
        else if(settings.name == "/search") {
          final List<Product> args = settings.arguments;

          return SlideDownRoute(
            page: (BuildContext context) => SearchResults
            (
              products: args,
            )
          );  
        }
        else if(settings.name == "/category") {
          final String args = settings.arguments;

          return MaterialPageRoute(builder: (context) => FutureBuilder(
            future: catalogue,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(!snapshot.hasData) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Container(
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
              return  CategoryScrollView(
                productList: snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data)).toList(),
                initialCategory: args,             
              );
            }
          ));
        }
        else {
          return MaterialPageRoute(builder: (context) => SplashScreen());
        }
      },
    );
  }

  addToBasket(Product product, int quantity) {
    setState(() {
      bool foundItem = false;
      checkoutData = checkoutData.map((Product index, int value) {
        if(index.id == product.id)  {
          foundItem = true;
          return MapEntry(product, value + quantity);
        }
        return MapEntry(index, value);
      });
      if(!foundItem) checkoutData[product] = quantity;
    });
  }

  removeFromBasket(String productID) {
    setState(() {
      checkoutData.removeWhere((Product product, int quantity) => product.id == productID);
    });
  }

  onLogin(FirebaseUser newUser) {
    navKey.currentState.pop();
    showDialog(context: navKey.currentState.overlay.context, builder: (context) => AlertDialog(title: Text("Success"), content: Text("You are now logged in.")));
  }

  onUserChange() {
    auth.currentUser().then((FirebaseUser newUser) {
      setState(() {
       user=newUser; 
      });
    });  
  }
}
