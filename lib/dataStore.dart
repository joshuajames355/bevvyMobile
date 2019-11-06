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
    if(!foundItem) checkoutData[product] = quantity;
  }

  void removeFromBasket(String productID) {
    checkoutData.removeWhere((Product product, int quantity) => product.id == productID);
  }

  void createFirestoreOrder() async {
    if (this.user == null) {
      throw('User is not logged in (or rather, not store in dataStore)');
    }
    var orderRef = await Firestore.instance.collection('orders').add({
      'basket': this.checkoutData.map((Product product, int quantity) => MapEntry<String, int>(product.id, quantity)),
      'customerID': this.user.uid,
      'status': 'new_order',
      'createdByUserAt': FieldValue.serverTimestamp(),
    });
    this.setOrderRef(orderRef);
  }

  void updateFirestoreOrder() async {
    if (!firestoreBasketInSync) {
      this.order.reference.updateData({
        'basket': this.checkoutData.map((Product product, int quantity) => MapEntry<String, int>(product.id, quantity)),
        'status': 'edited_order',
        'updatedLastByUserAt': FieldValue.serverTimestamp(),
      });
    } else {
      print('basket already in sync');
    }
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
      Map<String, int>.from(order.data['basket']),
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

  String get orderAmountString {
    double total = 0;
    this.checkoutData.forEach((Product k, int quantity){
      total += k.price * quantity;
    });
    return total.toStringAsFixed(2);
  }

  String get orderAmountStringWithCurrency {
    return '£' + orderAmountString;
  }

  List<ApplePayItem> get basketAsApplePayItems {
    List<ApplePayItem> items = [];
    this.checkoutData.forEach((Product product, int quantity) {
      for (var i = 0; i < quantity; i++) {
        items.add(ApplePayItem(
          label: product.title,
          amount: product.price.toStringAsFixed(2)));
      }
    });
    return items;
  }
}
