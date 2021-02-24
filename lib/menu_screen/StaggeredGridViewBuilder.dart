import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vidzemes_augstskola/lecture_graph/lecture_graph/Lecture_graph.dart';
import 'package:vidzemes_augstskola/webview/WebViewPage.dart';

bool _isLoading = true;

Widget StaggeredGridViewBuilder(
    BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  return new StaggeredGridView.count(
    crossAxisCount: 2,
    children:
        // ignore: deprecated_member_use
        snapshot.data.documents.map((DocumentSnapshot document) {
      return Card(
        margin: const EdgeInsets.all(5.0),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        shadowColor: Colors.black,
        color: hexToColor(document['bgcolor']),
        child: new InkWell(
          onTap: () {
            switch (document['activity']) {
              case "moodle":
              case "web":
                print(document['en']);
                print(document['lv']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewPage(url: document['lv'])),
                );
                break;
              case "lectures":
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lecture_graph()),
                );
                break;
              default:
                print(document['activity']);
            }
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Image.network(
                    document['icon_url'],
                    width: 40,
                    loadingBuilder: (BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                      //if loading is finished
                      if (loadingProgress == null){
                        //return image
                        return child;
                      } else {
                        //show loading
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Text(document['title_lv'],
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.left),
              )
            ],
          ),
        ),
      );
    }).toList(),
    // ignore: deprecated_member_use
    staggeredTiles: snapshot.data.documents.map((DocumentSnapshot document) {
      return StaggeredTile.fit(1);
    }).toList(),
  );
}
