// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CurrencyConverterHomePage(),
    );
  }
}

class CurrencyConverterHomePage extends StatefulWidget {
  @override
  _CurrencyConverterHomePageState createState() =>
      _CurrencyConverterHomePageState();
}

class _CurrencyConverterHomePageState extends State<CurrencyConverterHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _convertedAmount = 0.0;
  bool _isLoading = false;

  Future<Map<String, dynamic>> _fetchExchangeRates() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://api.exchangerate.host/latest?base=$_fromCurrency&symbols=$_toCurrency'));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  void _convertCurrency() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = await _fetchExchangeRates();
      setState(() {
        _convertedAmount = double.parse(_amountController.text) *
            data['rates'][_toCurrency];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Amount'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField<String>(
                      value: _fromCurrency,
                      onChanged: (value) {
                        setState(() {
                          _fromCurrency = value!;
                        });
                      },
                      items: ['USD', 'EUR', 'GBP', 'JPY']
                          .map((currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ))
                          .toList(),
                      decoration: InputDecoration(labelText: 'From Currency'),
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField<String>(
                      value: _toCurrency,
                      onChanged: (value) {
                        setState(() {
                          _toCurrency = value!;
                        });
                      },
                      items: ['USD', 'EUR', 'GBP', 'JPY']
                          .map((currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ))
                          .toList(),
                      decoration: InputDecoration(labelText: 'To Currency'),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _convertCurrency,
                      child: Text('Convert'),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      _convertedAmount.toStringAsFixed(2),
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
