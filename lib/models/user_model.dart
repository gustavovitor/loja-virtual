import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  bool isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();

  static UserModel of(BuildContext context) => ScopedModel.of<UserModel>(context);

  void signUp(
      {@required Map<String, dynamic> userData,
      @required String password,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) {
    _startLoading();

    _auth
        .createUserWithEmailAndPassword(
            email: userData['email'], password: password)
        .then((value) async {
      firebaseUser = value;

      await _saveUserData(userData);

      onSuccess();

      _stopLoading();
    }).catchError((error) {
      onFail();

      _stopLoading();
    });
  }


  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void signIn({
      @required String email,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail
  }) async {
    _startLoading();
    _auth.signInWithEmailAndPassword(email: email, password: pass)
      .then((user) async {
        firebaseUser = user;
        await _loadCurrentUser();
        onSuccess();
        _stopLoading();
        notifyListeners();
      }).catchError((error) {
        onFail();
        _stopLoading();
        notifyListeners();
      });
  }

  void recoverPassword(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  bool isLoggedIn() {
    return firebaseUser != null;
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .setData(userData);
  }

  void _startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null) {
      firebaseUser = await _auth.currentUser();
    }
    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot userDoc = await Firestore.instance.collection("users").document(firebaseUser.uid).get();
        userData = userDoc.data;
      }
    }
    notifyListeners();
  }

  void signOut() async {
    await _auth.signOut();
    firebaseUser = null;
    userData = Map();

    notifyListeners();
  }
}
