//import 'package:pocket_bus/Screens/shared_widgets.dart';
//import 'package:pocket_bus/StaticValues.dart';
//import 'package:flutter/material.dart';
//import 'package:webfeed/webfeed.dart';
//import 'package:http/http.dart' as http;
//
//class RssFeedScreen extends StatelessWidget {
//  Future<RssFeed> fetchFeed() async {
//    final response = await http.get(StaticValues.foliRssFeedUrl);
//
//    return RssFeed.parse(response.body);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder<RssFeed>(
//        future: fetchFeed(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) {
//            return const CenterSpinner();
//          }
//
//          final List<RssItem> rssItems = snapshot.data.items;
//
//          return ListView.builder(
//            itemCount: rssItems.length,
//            itemBuilder: (BuildContext context, int index) {
//              print(index);
//              print(rssItems[index].title);
//              return RssFeedItem(rssItem: rssItems[index]);
//            },
//          );
//        });
//  }
//}
//
//class RssFeedItem extends StatelessWidget {
//  final RssItem rssItem;
//  const RssFeedItem({Key key, @required this.rssItem}) : super(key: key);
//  @override
//  Widget build(BuildContext context) {
//    return ListTile(
//      title: Text(rssItem.title),
//    );
//  }
//}
