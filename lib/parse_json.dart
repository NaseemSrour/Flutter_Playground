import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// This file demonstartes how to fetch a (huge) json file, and parsing it into Item
// list and displaying it, using Isolate (another thread) in order not to lag
// the app.
// I'll use this to parse into ITEMs.

// The item I want to display class, in this case Item.
class Item {
  final int businessID;
  final int price;
  final String name;
  final String desc;
  final String thumbnailUrl;

  Item({this.businessID, this.price, this.name, this.desc, this.thumbnailUrl});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      businessID: json['business_id'] as int,
      price: json['price'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String,
      // thumbnailUrl: json['image'] as String,
    );
  }
} // end of class Item

// A function that converts a response body into a List<Item>.
List<Item> parseItems(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Item>((json) => Item.fromJson(json)).toList();
}

// HTTP GET request: Fetch items from internet (json)
Future<List<Item>> fetchItems(http.Client client) async {
  final response = await client
      .get('https://mocki.io/v1/7df2ab0b-919b-4625-8df4-e76d4d22b886');

  // 'https://jsonplaceholder.typicode.com/albums' // random json from the internet 3ben ma yser el json ta3e deployed online
  // because localhost mzbtish. this returns Album{userId, id, title}.

  // Use the compute function to run parseItems in a separate isolate (thread).
  String body = utf8.decode(
      response.bodyBytes); // take response.bodyBytes instead of response.body
  // because we have Arabic, and want to decode it to UTF-8.
  // Maybe if the serevr responded with a Header charset=utf-8 maybe we wouldn't need this, and would only
  // pass response.body here below:
  return compute(parseItems, body);
}

// Another app instead of the one in main.dart, that parses a json:
class MyListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Parsing Into Lists';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Item>>(
        future: fetchItems(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print("Errrrrrror: " + snapshot.error);

          return snapshot.hasData
              ? ItemsList(items: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

// The actual list in the app:
class ItemsList extends StatelessWidget {
  final List<Item> items;

  ItemsList({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
            leading: Text("zib"),
            title: Text(items[index].name), // filling it
            trailing: Text("₪" + items[index].price.toString()));
      },
    );
  }
}
