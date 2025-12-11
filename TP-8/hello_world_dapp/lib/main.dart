import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contract_linking.dart';
import 'helloUI.dart';

void main() {
  runApp(MyApp()); // [cite: 373]
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Injection du Provider pour qu'il soit accessible partout
    return ChangeNotifierProvider<ContractLinking>(
      create: (_) => ContractLinking(), // [cite: 377-378]
      child: MaterialApp(
        title: "Hello World",
        theme: ThemeData(
          brightness: Brightness.dark, // [cite: 387]
          primaryColor: Colors.cyan[400], // [cite: 388]
          hintColor: Colors.deepOrange[200], // [cite: 389]
        ),
        home: HelloUI(), // [cite: 390]
      ),
    );
  }
}
