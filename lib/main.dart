import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/categoryScrollView.dart';
import 'package:bevvymobile/checkout.dart';
import 'package:bevvymobile/createAccount.dart';
import 'package:bevvymobile/createAccountSMS.dart';
import 'package:bevvymobile/globals.dart';
import 'package:bevvymobile/homeNavBar.dart';
import 'package:bevvymobile/myOrders.dart';
import 'package:bevvymobile/orderScreen.dart';
import 'package:bevvymobile/searchResults.dart';
import 'package:bevvymobile/transitions.dart';
import 'package:bevvymobile/order.dart';
import 'package:bevvymobile/product.dart';
import 'package:bevvymobile/paymentMethods.dart';
import 'package:bevvymobile/productScreen.dart';
import 'package:bevvymobile/accountDetails.dart';
import 'package:bevvymobile/storeFrontHome.dart';
import 'package:bevvymobile/splashScreen.dart';
import 'package:bevvymobile/config.dart';
import 'package:bevvymobile/dataStore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

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
  FirebaseUser user;
  final GlobalKey<NavigatorState> navKey = new GlobalKey<NavigatorState>();
  Future<QuerySnapshot> catalogue;
  Stream<QuerySnapshot> paymentMethodsStream;
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod selectedMethod;
  DataStore dataStore;
  RemoteConfig remoteConfig;
  int initialPage = 0;

  @override
  initState() {
    super.initState();
    dataStore = DataStore();
    
    catalogue = widget.store.collection("catalogue").where("available", isEqualTo: true).getDocuments();

    //Used to ensure persistance.
    auth.currentUser().then(handleAuthStateChange);
    auth.onAuthStateChanged.listen(handleAuthStateChange);

    new Future.delayed(Duration.zero, () async {
      var config = AppConfig.of(context);
      StripePayment.setOptions(
        StripeOptions(publishableKey: config.stripePublishableKey,
                      merchantId: config.stripeMerchantId,
                      androidPayMode: config.stripeAndroidPayMode));

      remoteConfig = await RemoteConfig.instance;
      await remoteConfig.setDefaults({"delivery_center_lon" : -1.5849, "delivery_center_lat" : 54.7753, "delivery_radius" : 5, "delivery_fee" : 350, "delivery_free_after" : 2500});
      await remoteConfig.fetch();
      remoteConfig.activateFetched();
    });

    SharedPreferences.getInstance().then((SharedPreferences prefs)
    {
      if(prefs.getBool("logged_in") ?? false)
      {
        navKey.currentState.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }
    });
  }

  handleAuthStateChange(FirebaseUser updatedUser) async {
    setState(() {
      user = updatedUser;
      dataStore.user = updatedUser;
    });
    if (updatedUser == null) {
      // Logout
      navKey.currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("logged_in", false);
    } else {
      Crashlytics.instance.setUserIdentifier(updatedUser.uid);

      var userDocumentRef = Firestore.instance.collection('users').document(updatedUser.uid);
      var ds = await userDocumentRef.get();

      paymentMethodsStream = Firestore.instance.collection('users').document(updatedUser.uid).collection('payment_methods').snapshots();
      paymentMethodsStream.handleError((error) {
        //Crashlytics.
      });
      paymentMethodsStream.listen((QuerySnapshot query) async {
        setState(() {
          paymentMethods = query.documents.map((DocumentSnapshot x ) => PaymentMethod.fromJson(x.data["asJSON"])).toList();
        });
        if(selectedMethod == null)
        {
          setInitialPaymentMethod();
        }
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("logged_in", true);

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
          onGenerateRoute: onGenerateRoute,

    );
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if(settings.name == "/") {
      return MaterialPageRoute(builder: (context) => SplashScreen());
    }
    else if(settings.name == "/home") {
      return platformPageRoute(context: context, builder: (BuildContext _) => NavBarScaffold(
        onGenerateRoute: (RouteSettings settings){
          if(settings.name == "/"){
            return CupertinoPageRoute(builder: (BuildContext _) => FutureBuilder(
              future: catalogue,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(!snapshot.hasData) return Container();

                List<Product> productList = snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data, id: x.documentID)).toList();

                Map<String, List<Product>> productListByCategory = Map<String, List<Product>>();
                productList.forEach((Product x) {
                  if(productListByCategory.containsKey(x.category)) productListByCategory[x.category].add(x);
                  else productListByCategory[x.category] = [x];
                });
              
                return  StreamBuilder(
                  stream: Firestore.instance.collection("orders").where("customerID", isEqualTo: user.uid).snapshots(),
                  builder:  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(!snapshot.hasData) return Container();
              
                    return StoreFrontHome(
                        gotoMyOrders: () => Navigator.pushNamed(context, "/myOrders"),
                        statusNames: Map<String,String>.from(jsonDecode(remoteConfig.getString("order_state_descriptions"))),
                        productListByCategory: productListByCategory,
                        onOrderAgain: (Order order){orderAgain(order); Navigator.pushNamed(context, "/basket");},
                        orders: snapshot.data.documents.map((DocumentSnapshot snap) => Order.fromFirestore(data: snap.data.cast<String, dynamic>(), orderID: snap.documentID)).toList(),
                    );
                  }                    
                );
              }
              ),
              settings: RouteSettings(name: "/home", isInitialRoute: true));
            }
            else if(settings.name=="/basket")
            {
              return CupertinoPageRoute(builder: (BuildContext _) =>  Basket(
                dataStore: dataStore,
                removeFromBasket: removeFromBasket,
                deliveryFee: 0,
                freeDeliveryMinimun: 0,
              ),
              settings: RouteSettings(name: "/basket", isInitialRoute: true));
            }
            else if(settings.name=="/accountDetails")
            {
              return CupertinoPageRoute(builder: (BuildContext _) => StreamBuilder(
                stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if(!snapshot.hasData) {
                    return Container();
                  }
                  return  AccountDetails(
                    user: user,
                    onUserChange: onUserChange,
                    userDocument: snapshot.data,
                  );
                }
              ),
              settings: RouteSettings(name: "/accountDetails", isInitialRoute: true));
            }
            else if(settings.name == "/product")
            {
              final Product args = settings.arguments;

              return MaterialPageRoute(builder: (context) => ProductScreen(
                  product: args, 
                  addToBasket: addToBasket,
                  dataStore: dataStore ,
                )
              );
            }
            else if(settings.name == "/myOrders") {
              return CupertinoPageRoute(builder: (BuildContext context) => StreamBuilder(
                stream: Firestore.instance.collection("orders").where("customerID", isEqualTo: user.uid).snapshots(),
                builder:  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(!snapshot.hasData) return Container();
                  
                  return MyOrders
                  (
                    orders: snapshot.data.documents.map((DocumentSnapshot snap) => Order.fromFirestore(data: snap.data.cast<String, dynamic>(), orderID: snap.documentID)).toList(),
                    statusNames: Map<String,String>.from(jsonDecode(remoteConfig.getString("order_state_descriptions"))),
                    onOrderAgain: (Order order){orderAgain(order); Navigator.pushNamed(context, "/basket");},
                  );
                }),
              settings: RouteSettings(name: "/accountDetails", isInitialRoute: true));
            }
            else if(settings.name == "/order") {
              final String orderID = settings.arguments;

              return MaterialPageRoute(
                builder: (BuildContext context) => StreamBuilder(
                  stream: Firestore.instance.collection("orders").document(orderID).snapshots(),
                  builder:  (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if(!snapshot.hasData) return Container();
                      
                    return OrderScreen
                    (
                      statusNames: Map<String,String>.from(jsonDecode(remoteConfig.getString("order_state_descriptions"))),
                      order: Order.fromFirestore(data: snapshot.data.data, orderID: orderID),
                      onOrderAgain: (Order order){orderAgain(order); Navigator.pushNamed(context, "/basket");},
                    );
                  }
                )
              );  
            }
            else if (settings.name == "/checkout") {
              return SlideLeftRoute(
                page: (BuildContext context) => Checkout(
                  dataStore: dataStore,
                  paymentMethod: selectedMethod,
                  deliveryCenterLat: remoteConfig.getDouble("delivery_center_lat"),
                  deliveryCenterLon: remoteConfig.getDouble("delivery_center_lon"),
                  deliveryRadius: remoteConfig.getDouble("delivery_radius"),
                  statusNames: (remoteConfig != null && remoteConfig.lastFetchStatus == LastFetchStatus.success) ? Map<String,String>.from(jsonDecode(remoteConfig.getString("order_state_descriptions"))) : Map<String, String>(),
                ), 
              );   
            }
            else if(settings.name == "/paymentMethods") {
              return MaterialPageRoute(builder: (context) => PaymentMethods(
                user: user,
                paymentMethods: paymentMethods,      
                selectedMethod: selectedMethod,
                onChangeSelectedMethod: (PaymentMethod method) async {
                  setState(() {
                    selectedMethod = method;
                  });
                  String toDisk = method.id;
                  if(method.type == "googlepay") toDisk = "googlepay";
                  if(method.type == "applepay") toDisk = "applepay";
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString("paymentMethods", toDisk);
                },  
              )); 
            }
            else if(settings.name == "/search") {
              return SlideDownRoute(
                page: (BuildContext context) => FutureBuilder(
                  future: catalogue,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(!snapshot.hasData) return Container();
                    
                    return SearchResults
                    (
                      productList: snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data, id: x.documentID)).toList(),
                    );
                  }
                )
              );  
            }
            else if(settings.name == "/category") {
              final String args = settings.arguments;

              return MaterialPageRoute(builder: (context) => FutureBuilder(
                future: catalogue,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(!snapshot.hasData) return Container();

                  return  CategoryScrollView(
                    productList: snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data, id: x.documentID)).toList(),
                    initialCategory: args,             
                  );
                }
              ));
            }
            return platformPageRoute(context: context, builder: (BuildContext _) => Container());
          },
        ),
      );
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
  }

  addToBasket(Product product, int quantity) {
    setState(() {
      dataStore.addProduct(product, quantity);
    });
  }

  removeFromBasket(String productID) {
    setState(() {
      dataStore.removeFromBasket(productID);
    });
  }

  onLogin(FirebaseUser newUser) {
    navKey.currentState.pop();
    showPlatformDialog(androidBarrierDismissible: true,context: navKey.currentState.overlay.context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("Success"), content: Text("You are now logged in.")));
  }

  onUserChange() {
    auth.currentUser().then((FirebaseUser newUser) {
      setState(() {
       user=newUser; 
      });
    });  
  }

  setInitialPaymentMethod() async
  {
    //sets paymentMethod to method stored in sharedPreferences, otherwise first card (if it exists), otherwise native pay (if supported).
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fromDisk;
    try
    {
      fromDisk = prefs.getString("paymentMethods");
    } catch (e)
    {
      fromDisk =" ";
      print(e);
    }

    if(fromDisk != "applepay" && fromDisk != "googlepay"){
      for(int x = 0; x < paymentMethods.length; x++){
        if(paymentMethods[x].id == fromDisk){
          selectedMethod = paymentMethods[x];
          return;
        }
      }
    }

    bool canMakeNativePayments;
    try {
      canMakeNativePayments = await StripePayment.canMakeNativePayPayments([]);
      } catch (e) {
      print(e);
    }

    if((fromDisk == "applepay" || fromDisk == "googlepay") && canMakeNativePayments){
      selectedMethod = PaymentMethod(type: (Platform.isIOS ? 'applepay' : 'googlepay'));
      return;
    }

    if (paymentMethods.length > 0) {
      setState(() => selectedMethod = paymentMethods[0]);
    } else  {
        if (canMakeNativePayments) {
          setState(() => selectedMethod = PaymentMethod(type: (Platform.isIOS ? 'applepay' : 'googlepay')));
        }
    }
  }

  void orderAgain(Order order)
  {
    dataStore.reset();
    catalogue.then((QuerySnapshot snap)
    {
      var products = snap.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data, id: x.documentID)).toList();

      for(int x = 0; x < products.length; x++)
      {        
        List<OrderItem> orderItems = order.products.where((OrderItem item) => (item.id == products[x].id)).toList();
        if(orderItems.length != 1) continue;
        dataStore.addProduct(products[x], orderItems[0].quantity);        
      }
      //rerender
      setState(() {});
    });
  }
}

typedef Route<dynamic> OnGenerateRoute(RouteSettings settings);


class NavBarScaffold extends StatefulWidget
{
  const NavBarScaffold({ Key key, this.onGenerateRoute}) :  super(key: key);

  final OnGenerateRoute onGenerateRoute;

  @override
  _NavBarScaffoldState createState() => _NavBarScaffoldState();
}

class _NavBarScaffoldState extends State<NavBarScaffold> {
  GlobalKey<NavigatorState> navKey = GlobalKey();
  Widget build(BuildContext context)  {
    return Scaffold
    (
      body: Navigator
      (
        key: navKey,
        onGenerateRoute: widget.onGenerateRoute,
      ),

      bottomNavigationBar: HomeNavBar(navKey: navKey),
    );
  }
}