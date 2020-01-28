import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bevvymobile/product.dart';
import 'package:collection/collection.dart' show MapEquality;
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:math';

typedef void OrderUpdateEvent(DocumentSnapshot order);

class DataStore {
  Map<Product, int> checkoutData;
  Stream<DocumentSnapshot> orderStream;
  DocumentSnapshot order;
  DocumentReference orderRef;
  FirebaseUser user;

  Map<int, OrderUpdateEvent> onOrderUpdateEvents = Map<int, OrderUpdateEvent>();
  Random rand = Random();

  DataStore() {
    this.checkoutData = Map<Product, int>();
  }

  void addProduct(Product product, int quantity) {
    bool foundItem = false;
    checkoutData = checkoutData.map((Product index, int value) {
      if(index.id == product.id)  {
        foundItem = true;
        return MapEntry(product, value + quantity);
      }
      return MapEntry(index, value);
    });
    if(!foundItem && quantity > 0) checkoutData[product] = quantity;
  }

  void removeFromBasket(String productID) {
    checkoutData.removeWhere((Product product, int quantity) => product.id == productID);
  }

  void createFirestoreOrder() async {
    if (this.user == null) {
      throw('User is not logged in (or rather, not store in dataStore)');
    }

    var orderRef = await Firestore.instance.collection('orders').add({
      'basket': this.firestoreBasketFormat,
      'customerID': this.user.uid,
      'status': 'new_order',
      'createdByUserAt': FieldValue.serverTimestamp(),
      'updatedLastByUserAt': FieldValue.serverTimestamp(),
    });
    this.setOrderRef(orderRef);
  }

  void updateFirestoreOrder() async {
    if (!firestoreBasketInSync) {
      this.order.reference.updateData({
        'basket': this.firestoreBasketFormat,
        'status': 'edited_order',
        'updatedLastByUserAt': FieldValue.serverTimestamp(),
      });
    } else {
      print('basket already in sync');
    }
  }

  List<Map<String, dynamic>> get firestoreBasketFormat{
    return List.from(
      this.checkoutData.map((Product product, int quantity) => 
        MapEntry(product.id, {
          "id": product.id, 
          "name": product.title, 
          "quantity": quantity, 
          "price": product.price}
        )
      ).values
    );
  }

  void createOrUpdateFirestoreOrder() async {
    try {
      if (this.orderRef == null) {
        createFirestoreOrder();
      } else {
        updateFirestoreOrder();
      }
    } catch (error) {
      print('err' + error.toString());
      rethrow;
    }
  }

  bool get firestoreBasketInSync {
    var me = new MapEquality<String, int>();
    return me.equals(
      Map<String, int>.fromIterable(order.data['basket'], key: (dynamic obj) => obj["id"], value : (dynamic obj) => obj["quantity"]),
      this.checkoutData.map((Product product, int quantity) => MapEntry<String, int>(product.id, quantity)));
  }

  void reset() {
    this.orderRef = null;
    this.orderStream = null;
    this.order = null;
    this.checkoutData = Map<Product, int>();
    this.onOrderUpdateEvents = Map<int, OrderUpdateEvent>();
  }

  void setOrderRef(DocumentReference ref) {
    this.orderRef = ref;
    this.orderStream = this.orderRef.snapshots();
    this.orderStream.listen((DocumentSnapshot snap) async {
      this.order = snap;
      this.onOrderUpdateEvents.forEach((int key, OrderUpdateEvent event) => event(snap));
    });
  }

  int subscribeToOrderUpdate(OrderUpdateEvent event)
  {
    int key = rand.nextInt(1<<32);
    this.onOrderUpdateEvents[key] = event;
    return key;
  }

  void unsubscribeFromOrderUpdates(int id)
  {
    if(id < this.onOrderUpdateEvents.length) this.onOrderUpdateEvents.remove(id);
  }

  int get orderAmountInt{
    int basketSubtotal = 0;
    this.checkoutData.forEach((Product k, int quantity){
      basketSubtotal += k.price * quantity;
    });

    int otherchargesBasketSubtotal = 0;
    this.order?.data['othercharges']?.forEach((charge) => {
      if (charge['type'] == 'fixed_amount') {
        otherchargesBasketSubtotal += charge['value']
      } else if (charge['type'] == 'percentage_basket') {
        otherchargesBasketSubtotal += ((charge['value'] / 100) * basketSubtotal)
      }
    });

    int otherchargesTotalSubtotal = 0;
    this.order?.data['othercharges']?.forEach((charge) => {
      if (charge['type'] == 'percentage_total') {
        otherchargesTotalSubtotal += ((charge['value'] / 100) * (basketSubtotal + otherchargesBasketSubtotal))
      }
    });
    return basketSubtotal + otherchargesBasketSubtotal + otherchargesTotalSubtotal;
  }

  double get orderAmountDouble{
    return (this.orderAmountInt/100);
  }

  String get orderAmountString {
    return orderAmountDouble.toStringAsFixed(2);
  }

  String get orderAmountStringWithCurrency {
    return '£' + orderAmountString;
  }

  List<ApplePayItem> get basketAsApplePayItems {
    // https://developer.apple.com/documentation/passkit/pkpaymentrequest/1619231-paymentsummaryitems
    List<ApplePayItem> items = [];
    this.checkoutData.forEach((Product product, int quantity) {
      for (var i = 0; i < quantity; i++) {
        items.add(ApplePayItem(
          label: product.title,
          amount: product.priceAsDouble.toStringAsFixed(2)));
      }
    });

    // Grand total summary row, with company name as label
    items.add(ApplePayItem(
      label: 'Jovi',
      amount: this.orderAmountString
    ));

    return items;
  }

  Future<int> remoteOrderAmountInt() {
   if (this.order?.data['status'] == 'synced_editing_order' && this.order?.metadata?.hasPendingWrites == false) {
      return Future.value(this.order?.data['serverOrderTotal']);
    } else {
      return this.orderRef.snapshots().firstWhere((DocumentSnapshot snap) {
        return (snap?.data['status'] == 'synced_editing_order' && snap?.metadata?.hasPendingWrites == false);
      }).then((DocumentSnapshot snap) async { return this.order?.data['serverOrderTotal']; });
    }
  }
}
