import 'package:flutter/material.dart';

// ignore: camel_case_types
class Coin_List extends StatefulWidget {
  final String title;
  
  Coin_List({this.title});
  
  @override
  _Coin_ListState createState() => _Coin_ListState();
}

// ignore: camel_case_types
class _Coin_ListState extends State<Coin_List> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(this.widget.title),
      ),
      // ListView somente para teste, após: ListView.Builder
      body: new ListView(
        children: [
          Container(
            height: 50,
            color: Colors.amber[600],
            child: const Center(child: Text('USD')),
          ),
          Container(
            height: 50,
            color: Colors.amber[500],
            child: const Center(child: Text('CAD')),
          ),
          Container(
            height: 50,
            color: Colors.amber[100],
            child: const Center(child: Text('JPY')),
          ),
        ],
      ),
    );
  }
}
