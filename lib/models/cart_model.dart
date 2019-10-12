import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/data/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  UserModel user;
  List<CartProduct> products = [];

  CartModel(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
  }

  String couponCode;
  String shipCEP;
  int discountPercentage = 0;

  bool isLoading = false;

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .add(cartProduct.toMap())
        .then((productOnBase) {
      cartProduct.cid = productOnBase.documentID;
    });
    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .document(cartProduct.cid)
        .delete();
    products.remove(cartProduct);
    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  void _loadCartItems() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .getDocuments();

    products = querySnapshot.documents.map((document) {
      return CartProduct.fromDocument(document);
    }).toList();

    notifyListeners();
  }

  double getProductPrice() {
    double price = 0.0;
    for (CartProduct c in products) {
      if (c.productData != null) {
        price += c.quantity * c.productData.price;
      }
    }
    return price;
  }

  double getDiscount() {
    return getProductPrice() * discountPercentage / 100;
  }

  double getShipPrice() {
    return 9.99;
  }

  void updatePrices() {
    notifyListeners();
  }

  Future<String> finishOrder() async {
    if (products.length == 0) return null;
    isLoading = true;
    notifyListeners();

    double productsPrice = getProductPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    DocumentReference reference =
        await Firestore.instance.collection('orders').add({
      'clientId': user.firebaseUser.uid,
      'products': products.map((cartProduct) => cartProduct.toMap()).toList(),
      'shipPrice': shipPrice,
      'productsPrice': productsPrice,
      'discount': discount,
      'totalPrice': productsPrice - discount + shipPrice,
      'status': 1
    });

    await Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('orders')
        .document(reference.documentID)
        .setData({'orderId': reference.documentID});

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .getDocuments();

    for (DocumentSnapshot doc in querySnapshot.documents) {
      doc.reference.delete();
    }

    products.clear();
    discountPercentage = 0;
    couponCode = null;
    isLoading = false;

    notifyListeners();

    return reference.documentID;
  }
}
