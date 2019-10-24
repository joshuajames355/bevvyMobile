import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bevvymobile/product.dart';
import 'package:collection/collection.dart' show MapEquality;
import 'package:stripe_payment/stripe_payment.dart';

class DataStore {
  Map<Product, int> checkoutData;
  Stream<DocumentSnapshot> orderStream;
  DocumentSnapshot order;
  DocumentReference orderRef;

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

  void createFirestoreOrder(String uid) async {
    var orderRef = await Firestore.instance.collection('orders').add({
      'basket': this.checkoutData.map((Product product, int quantity) => MapEntry<String, int>(product.id, quantity)),
      'customerID': uid,
      'status': 'new_order',
    });
    this.setOrderRef(orderRef);
  }

  void updateFirestoreOrder() async {
    if (!firestoreBasketInSync) {
      this.order.reference.updateData({
        'basket': this.checkoutData.map((Product product, int quantity) => MapEntry<String, int>(product.id, quantity)),
        'status': 'edited_order',
      });
    } else {
      print('basket already in sync');
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
  }

  void setOrderRef(DocumentReference ref) {
    this.orderRef = ref;
    this.orderStream = this.orderRef.snapshots();
    this.orderStream.listen((DocumentSnapshot snap) async {
      this.order = snap;
    });
  }

  String get orderAmountString {
    double total = 0;
    this.checkoutData.forEach((Product k, int quantity){
      total += k.price * quantity;
    });
    return '£' + total.toStringAsFixed(2);
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
