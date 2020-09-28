import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// ignore: camel_case_types
class Coin_List extends StatefulWidget {
  final String title; // Title bar, o titulo que a pagina terá


  Coin_List({this.title});

  @override
  _Coin_ListState createState() => _Coin_ListState();
}

// ignore: camel_case_types
class _Coin_ListState extends State<Coin_List> {
  String dropdownValue,  newCurrency;

  final List<String> items = [
  "CAD", "HKD", "ISK", "PHP", "DKK", "HUF",
  "CZK", "GBP", "RON", "SEK", "IDR", "INR",
  "BRL", "RUB", "HRK", "JPY", "THB", "CHF",
  "EUR", "MYR", "BGN", "TRY", "CNY", "NOK",
  "NZD", "ZAR", "USD", "MXN", "SGD", "AUD",
  "ILS", "KRW", "PLN"
  ];

  final textConverted = TextEditingController(),textConverter = TextEditingController();
  @override
  void initState() {
    textConverter.text = '0.00';
    dropdownValue = 'USD';
    newCurrency = 'EUR';
    textConverted.text = '0.00';
    super.initState();
  }

  Future<String> get _localPath async {
    // pega o diretorio do celular
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> _localFile(String coinPath) async {
    // Cria referência do arquivo que quero
    final path = await _localPath;
    print(coinPath);
    return File('$path/$coinPath.json');
  }

  Future<Currency> fetchCurrency() async {
    // metodo que pega os dados da API

    final file =
        await _localFile(newCurrency); // pega as informações de arquivo local

    // verifica se já existe a informação no arquivo
    if (file.existsSync()) {
      if (file.readAsStringSync().contains("${DateTime.now().year}"
          "-${(DateTime.now().month < 10) ? 0 : ""}${DateTime.now().month}"
          "-${DateTime.now().day}")) {
        print("Tem arquivo e tem a data");
        return Currency.fromJson(
            json.decode(file.readAsStringSync())); // incorpóra em um json
      } else {
        print("Tem arquivo e Nao tem a data");
        final response = await http
            .get('https://api.exchangeratesapi.io/latest?base=$newCurrency');
        if (response.statusCode == 200) {
          // se deu certo o request,
          file.createSync(); // ele cria um arquivo novo,
          file.writeAsStringSync(response.body); // copia o corpo da resposta
          print(file
              .readAsStringSync()); // printa a resposta pra ver se está tudo certo (a fins de debug somente)

          var jsonresponse =
              await Currency.fromJson(json.decode(file.readAsStringSync()));

          if (jsonresponse != null) return jsonresponse; // incorpora em um Json
        } else {
          // joga excessao se o servidor nao responder a tempo
          throw Exception('Failed to load currency');
        }
      }
    } else {
      print("Nao tem arquivo");
      final response = await http
          .get('https://api.exchangeratesapi.io/latest?base=$newCurrency');
      if (response.statusCode == 200) {
        // se deu certo o request,
        file.createSync(); // ele cria um arquivo novo,
        file.writeAsStringSync(response.body); // copia o corpo da resposta
        print(file
            .readAsStringSync()); // printa a resposta pra ver se está tudo certo (a fins de debug somente)

        var jsonresponse =
            await Currency.fromJson(json.decode(file.readAsStringSync()));

        if (true) return jsonresponse; // incorpora em um Json
      } else {
        // joga excessao se o servidor nao responder a tempo
        throw Exception('Failed to load currency');
      }
    }
  }

  @override
  void dispose() {
    textConverter.dispose();
    super.dispose();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>(); // pra manejar o Refresh Indicator
  // e fazer com que o widget faça refresh

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(
          children: [
            new Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              padding: EdgeInsets.only(top: 30),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${this.widget.title}", style: TextStyle(fontSize: 30, color: Colors.deepPurpleAccent),),
                new IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () {
                      //atualizar o arquivo (refresh)
                      _refreshIndicatorKey.currentState.show();
                    }),
              ],
            ),),
            Center(
              child: new RefreshIndicator(
                onRefresh: fetchCurrency,
                key: _refreshIndicatorKey, // colocando a KEY
                child: new FutureBuilder<Currency>(
                    future: fetchCurrency(), // ele faz refresh desse future
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Container(
                              height: 40,
                            ),
                            new Container(
                              child: Text(
                                "Última Atualização de $newCurrency:\n${snapshot.data.date}", // mostra a ultima
                                // atualização e a ultima moeda colocada
                                textAlign: TextAlign.center,
                              ),
                            ),
                            new Container(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DropdownButton(
                                  value: newCurrency, // pega o valor atual da moeda base
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  items: items.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      newCurrency = newValue;
                                      _refreshIndicatorKey.currentState.show();
                                      textConverted.text =
                                      '${double.tryParse(textConverter.text) * snapshot.data.rates.values[dropdownValue]}';
                                      // aqui ele converte a moeda, passando por todas as etapas de conversao
                                    });
                                  },
                                ),
                                new Container(
                                  width: 20,
                                ),
                                new Container(
                                  width: 200,
                                  height: 30,
                                  child: new TextFormField(
                                    controller: textConverter, // usado para converter a moeda futuramente
                                    keyboardType: TextInputType.numberWithOptions(
                                        decimal: true, signed: false),
                                    style: TextStyle(fontSize: 20),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        if (textConverter.text.isEmpty)
                                          textConverter.text = '0.00';
                                        else {
                                          if (textConverter.text.contains(","))
                                            textConverter.text.replaceFirst(",", ".");
                                        }

                                        textConverted.text =
                                        '${double.tryParse(textConverter.text) * snapshot.data.rates.values[dropdownValue]}';
                                        // aqui ele converte a moeda, passando por todas as etapas de conversao, inclusive
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DropdownButton(
                                  value: dropdownValue, // ele troca o rating
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  items: snapshot.data.rates.values.keys
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownValue = newValue;
                                      textConverted.text =
                                      '${double.tryParse(textConverter.text) * snapshot.data.rates.values[dropdownValue]}';
                                    });
                                  },
                                ),
                                new Container(
                                  width: 20,
                                ),
                                new Container(
                                  width: 200,
                                  height: 30,
                                  child: new TextFormField(
                                    controller: textConverted,
                                    style: TextStyle(fontSize: 20),
                                    readOnly: true
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("ERRO ao comunicar"),
                        );
                      }

                      return Center(child: CircularProgressIndicator());
                    }),
              ),
            )
          ],
        )
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

  Currency({this.base, this.rates, this.date});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      base: json['base'],
      rates: Rates.fromJson(json['rates']), // as Map<String, Double>,
      date: json['date'],
    );
  }
}

class Rates {
  final Map<String, dynamic> values;

  Rates({this.values});

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
        values: json);
  }
}
