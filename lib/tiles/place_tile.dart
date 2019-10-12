import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceTile extends StatelessWidget {
  final DocumentSnapshot place;

  PlaceTile(this.place);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 100.0,
            child: Image.network(
              place.data['image'],
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  place.data['title'],
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
                Text(
                  place.data['address'],
                  textAlign: TextAlign.start,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        launch('https://www.google.com/maps/search/?api=1&query=${place.data['lat']},${place.data['long']}');
                      },
                      child: Text('Mapa'),
                      textColor: Colors.blue,
                      padding: EdgeInsets.zero,
                    ),
                    FlatButton(
                      onPressed: () {
                        launch('tel:${place.data['phone']}');
                      },
                      child: Text('Ligar'),
                      textColor: Colors.blue,
                      padding: EdgeInsets.zero,
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
