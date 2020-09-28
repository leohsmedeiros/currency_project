import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ignore: camel_case_types
class Coin_List extends StatefulWidget {
  final String title; // Title bar, o titulo que a pagina terá

  Coin_List({this.title});

  @override
  _Coin_ListState createState() => _Coin_ListState();
}

// ignore: camel_case_types
class _Coin_ListState extends State<Coin_List> {
  Future<Currency> fetchCurrency() async { // metodo que pega os dados da API
    final response = await http.get('https://api.ratesapi.io/api/latest');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Currency.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  String dropdownValue, textConverted;

  final textConverter = TextEditingController();
  @override
  void initState() {
    textConverter.text = '0.00';
    dropdownValue = 'USD';
    textConverted = '0.00';
    super.initState();
  }

  @override
  void dispose() {
    textConverter.dispose();
    super.dispose();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(this.widget.title),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              }),
        ],
      ),

      body: new RefreshIndicator(
        onRefresh: fetchCurrency,
        key: _refreshIndicatorKey,
        child: new FutureBuilder<Currency>(future: fetchCurrency(), builder: (context, snapshot) {
        if (snapshot.hasData) {
          return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Container(
                child: Text("Última Atualização: ${snapshot.data.date}"),
              ),
              new Container(
                width: 270,
                height: 30,
                child: TextFormField(
                  controller: textConverter,
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      if (textConverter.text.isEmpty)
                        textConverter.text = '0.00';
                      else {
                        if (textConverter.text.contains(","))
                          textConverter.text.replaceFirst(",", ".");
                      }

                      textConverted = '${double.tryParse(textConverter.text)*snapshot.data.rates.values[dropdownValue]}';
                    });
                  },// Only numbers can be entered
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                        color: Colors.deepPurple
                    ),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    items: snapshot.data.rates.values.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;

                      });
                    },
                  ), new Container(
                    width: 20,
                  ), new Container(
                      width: 200,
                      height: 30,
                      child: Text(textConverted, style: TextStyle(fontSize: 20),)
                  ),
                ],
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("ERRO ao comunicar"),);
        }

        return Center(child: CircularProgressIndicator());
      }),)
    );
  }
}

// GET https://api.ratesapi.io/api/latest
// Armazenar esses dados para uso futuro
// Informar que os dados são os últimos disponíveis
// Informar e alterar as moedas para conversão
// Botão para requisicao

class Currency {
  final String base, date;
  final Rates rates;

  Currency({this.base,
    this.rates,
    this.date
   });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      base: json['base'],
      rates: Rates.fromJson(json['rates']),// as Map<String, Double>,
      date: json['date'],
    );
  }
}

class Rates {
  final Map<String, dynamic> values;

  Rates({this.values});

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
      //keys: json.keys.toList(),
      values: json
    );
  }
}
