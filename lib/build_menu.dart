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
  final String category;

  Item(
      {this.businessID,
      this.price,
      this.name,
      this.desc,
      this.thumbnailUrl,
      this.category});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      businessID: json['userId'] as int,
      price: json['id'] as int,
      name: json['title'] as String,
      /*
      desc: json['desc'] as String,
      thumbnailUrl: json['image'] as String,
      category: json['category'] as String,
      */
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
  final response = await client.get(
      'https://jsonplaceholder.typicode.com/albums'); // random json from the internet 3ben ma yser el json ta3e deployed online
  // because localhost mzbtish. this returns Album{userId, id, title}.

  // Use the compute function to run parseItems in a separate isolate (thread).
  return compute(parseItems, response.body);
}

// Another app instead of the one in main.dart, that parses a json:
class MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Menu Building Demo';

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
          if (snapshot.hasError) print(snapshot.error);

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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(items[index].name), // filling it
            trailing: Icon(Icons.wifi));
      },
    );
  }
}

class MenuTabs extends StatelessWidget {
  final List<Tab> categoryTabs = <Tab>[
    Tab(text: 'FIRST'),
    Tab(text: 'SECOND'),
    Tab(text: 'THIRD'),
    Tab(text: 'FOURTH'),
    Tab(text: 'FIFTH'),
    Tab(text: 'SIXTH')
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categoryTabs.length,
      child: Scaffold(
        appBar: AppBar(
            bottom: TabBar(
              tabs: categoryTabs,
            ),
            title: Text('My Business Name')),
        body: ListView(
          children: <Widget>[
            ListTile(leading: Icon(Icons.map), title: Text('7abash')),
            ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('baquette 3ejel')),
            ListTile(leading: Icon(Icons.food_bank), title: Text('brocolli')),
          ],
        ),
      ),
    );
  }
}
