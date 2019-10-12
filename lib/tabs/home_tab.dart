import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Widget _buildBodyBackground() => Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 4, 125, 195),
        Colors.blueAccent
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
    )
    ),
    );

    return Stack(
      children: <Widget>[
        _buildBodyBackground(),
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Novidades'),
                centerTitle: true,
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: Firestore.instance
                .collection('home').orderBy('pos').getDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Container(
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                } else {
                  return SliverStaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 0.0,
                    crossAxisSpacing: 0.0,
                    staggeredTiles: snapshot.data.documents.map(
                      (document) {
                        return StaggeredTile.count(document.data['x'], document.data['y']);
                      }
                    ).toList(),
                    children: snapshot.data.documents.map(
                        (document) {
                        return FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: document.data['img'],
                          fit: BoxFit.cover
                        );
                      }
                    ).toList(),
                  );
                }
              },
            )
          ],
        )
      ],
    );
  }
}
