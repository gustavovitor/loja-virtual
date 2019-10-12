import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/data/cart_product.dart';
import 'package:loja_virtual/data/product_data.dart';
import 'package:loja_virtual/models/cart_model.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/login_screen.dart';

import 'cart_screen.dart';

class ProductScreen extends StatefulWidget {
  final ProductData product;

  ProductScreen(this.product);

  @override
  _ProductScreenState createState() => _ProductScreenState(product);
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductData product;

  _ProductScreenState(this.product);

  String size;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 0.9,
            child: Carousel(
              dotSize: 4.0,
              dotSpacing: 15.0,
              dotBgColor: Colors.transparent,
              dotColor: primaryColor,
              autoplay: false,
              images: product.images.map((url) {
                return NetworkImage(url);
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  product.title,
                  maxLines: 3,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                Text(
                  'R\$ ' + product.price.toStringAsFixed(2),
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  'Tamanho',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 34.0,
                  child: GridView(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.5
                    ),
                    children: product.sizes.map((s) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            size = s;
                          });
                        },
                        child: Container(
                          width: 50.0,
                          child: Text(s, style: TextStyle(color: size == s ? Colors.white : Colors.black),),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: size == s ? Theme.of(context).primaryColor : Colors.transparent,
                            border: Border.all(
                              width: 2.0,
                              color: size == s ? Theme.of(context).primaryColor : Colors.grey[500]
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    onPressed: size != null ? () {
                      if (UserModel.of(context).isLoggedIn()) {
                        CartProduct cartProduct = CartProduct();
                        cartProduct.size = size;
                        cartProduct.quantity = 1;
                        cartProduct.pid = product.id;
                        cartProduct.category = product.category;
                        cartProduct.productData = product;

                        CartModel.of(context).addCartItem(cartProduct);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartScreen()));
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LoginScreen())
                        );
                      }
                    } : null,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(UserModel.of(context).isLoggedIn() ? 'Adicionar ao Carrinho' : 'Entre para Comprar', style: TextStyle(fontSize: 18.0),),
                  ),
                ),
                SizedBox(height: 16.0,),
                Text(
                  'Descrição',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
                ),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
