
import 'package:bevvymobile/accountDetails.dart';
import 'package:bevvymobile/basket.dart';
import 'package:bevvymobile/dataStore.dart';
import 'package:bevvymobile/myOrders.dart';
import 'package:bevvymobile/order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bevvymobile/product.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bevvymobile/storeFrontHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key key, this.catalogue, this.user, this.dataStore, this.onUserChange, this.onOrderAgain, this.statusNames, this.removeFromBasket, this.initialPage, this.deliveryFee, this.freeDeliveryMinimun}) : super(key: key);

  final Future<QuerySnapshot> catalogue;
  final FirebaseUser user;
  final DataStore dataStore;
  final VoidFunc onUserChange;
  final OnOrderAgain onOrderAgain;
  final Map<String, String> statusNames;
  final RemoveFromBasketFunc removeFromBasket;
  final int initialPage;
  final double deliveryFee;
  final double freeDeliveryMinimun;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    PageController homePageController;
    CupertinoTabController homePageControllerIOS;

  @override
  void initState() {
    homePageController = PageController(initialPage: widget.initialPage);
    homePageControllerIOS = CupertinoTabController(initialIndex: widget.initialPage);

    super.initState();
  }

  @override
  Widget build(BuildContext context)  {
    return PlatformWidget
    (
      android: (_) => Scaffold
      (
        body: PageView.builder(
          controller: homePageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: getCurrentTabHomePage,
        ),
        bottomNavigationBar: BottomNavigationBar
        (
          type: BottomNavigationBarType.fixed,
          currentIndex: (homePageController.hasClients && homePageController.positions.length == 1) ? (homePageController.page ?? 0).round() : widget.initialPage,
          onTap: (int index){
          //setState triggers a rerender to update the currentIndex after animation completes
          if (homePageController.hasClients && homePageController.positions.length == 1)
            homePageController.animateToPage(index, duration: Duration(milliseconds: 150), curve: Curves.easeInOut).then((_) => setState((){}));
          },
          items: [
            BottomNavigationBarItem
            (
              title: Text("Home"),
              icon: Icon(IconData(59530, fontFamily: 'MaterialIcons')),
            ),
            BottomNavigationBarItem
            (
              title: Text("Basket"),
              icon: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
            ),
            BottomNavigationBarItem
            (
              title: Text("Account"),
              icon: Icon(IconData(59473, fontFamily: 'MaterialIcons')),
            ),
            BottomNavigationBarItem
            (
              title: Text("Orders"),
              icon: Icon(IconData(59485, fontFamily: 'MaterialIcons')),
            ),
          ]
        ),
      ),
      ios: (_) => CupertinoTabScaffold(
        tabBuilder: getCurrentTabHomePage,
        controller: homePageControllerIOS,
        tabBar: CupertinoTabBar(
          backgroundColor: Color(0xFF222222), 
          inactiveColor: Colors.white,
          items: [
            BottomNavigationBarItem
            (
              title: Text("Home"),
              icon: Icon(IconData(59530, fontFamily: 'MaterialIcons')),
            ),
            BottomNavigationBarItem
            (
              title: Text("Basket"),
              icon: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
            ),
            BottomNavigationBarItem
            (
              title: Text("Account"),
              icon: Icon(IconData(59473, fontFamily: 'MaterialIcons')),
            ),
            BottomNavigationBarItem
            (
              title: Text("Orders"),
              icon: Icon(IconData(59485, fontFamily: 'MaterialIcons')),
            ),
          ],
        ),
      ),      
    ); 
  }

  Widget getCurrentTabHomePage(BuildContext context, int selectedTab)
  {
    return selectedTab == 0 ? FutureBuilder(
      future: widget.catalogue,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) return placeHolderPage();

        List<Product> productList = snapshot.data.documents.map((DocumentSnapshot x ) => Product.fromFireStore(data: x.data)).toList();

        Map<String, List<Product>> productListByCategory = Map<String, List<Product>>();
        productList.forEach((Product x) {
          if(productListByCategory.containsKey(x.category)) productListByCategory[x.category].add(x);
          else productListByCategory[x.category] = [x];
        });
      
        return  WillPopScope(
          onWillPop: () {
            return Future.value(scaffoldKey.currentState.isDrawerOpen);
          },
          child:  StreamBuilder(
            stream: Firestore.instance.collection("orders").where("customerID", isEqualTo: widget.user.uid).snapshots(),
            builder:  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(!snapshot.hasData) return placeHolderPage();
        
              return StoreFrontHome(
                  gotoMyOrders: ()
                  {
                    if(isMaterial(context)) homePageController.animateToPage(4, duration: Duration(milliseconds: 150), curve: Curves.easeInOut).then((_) => setState((){}));
                    homePageControllerIOS.index=3;
                  },
                  statusNames: widget.statusNames,
                  productListByCategory: productListByCategory,
                  onOrderAgain: widget.onOrderAgain,
                  orders: snapshot.data.documents.map((DocumentSnapshot snap) => Order.fromFirestore(data: snap.data.cast<String, dynamic>(), orderID: snap.documentID)).toList(),
              );
            }
          )
        );
      }
    )
    : selectedTab == 1 ? Basket(
      dataStore: widget.dataStore,
      removeFromBasket: widget.removeFromBasket,
      deliveryFee: widget.deliveryFee,
      freeDeliveryMinimun: widget.freeDeliveryMinimun,
    )
    : selectedTab == 2 ? StreamBuilder(
      stream: Firestore.instance.collection('users').document(widget.user.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if(!snapshot.hasData) {
          return placeHolderPage();
        }
        return  AccountDetails(
          user: widget.user,
          onUserChange: widget.onUserChange,
          userDocument: snapshot.data,
        );
      }
    )
    : selectedTab == 3 ? StreamBuilder(
      stream: Firestore.instance.collection("orders").where("customerID", isEqualTo: widget.user.uid).snapshots(),
      builder:  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) return placeHolderPage();
        
        return MyOrders
        (
          orders: snapshot.data.documents.map((DocumentSnapshot snap) => Order.fromFirestore(data: snap.data.cast<String, dynamic>(), orderID: snap.documentID)).toList(),
          statusNames: widget.statusNames,
          onOrderAgain: widget.onOrderAgain,
        );
      }
    ) : Container();
  }

}

//Displayed when the page is not ready
Widget placeHolderPage()
{
  return WillPopScope(
    onWillPop: () async => false,
    child: Container(
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