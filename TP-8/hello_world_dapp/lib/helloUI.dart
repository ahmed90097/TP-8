import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contract_linking.dart'; // Assurez-vous que le chemin est bon

class HelloUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupération de l'instance du Provider
    var contractLink = Provider.of<ContractLinking>(context); // [cite: 349]

    TextEditingController yourNameController =
        TextEditingController(); // [cite: 349]

    return Scaffold(
      appBar: AppBar(title: Text("Hello World Dapp"), centerTitle: true),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          // Afficher un chargement si les données ne sont pas prêtes
          child: contractLink.isLoading
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hello ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              contractLink
                                  .deployedName, // Nom venant de la Blockchain
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.tealAccent,
                              ),
                            ), // [cite: 351]
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 29),
                          child: TextFormField(
                            controller: yourNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Your Name",
                              hintText: "What is your name?",
                              icon: Icon(Icons.drive_file_rename_outline),
                            ),
                          ), // [cite: 351]
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: ElevatedButton(
                            child: Text(
                              'Set Name',
                              style: TextStyle(fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // [cite: 351]
                            ),
                            onPressed: () {
                              // Appel de la fonction pour changer le nom
                              contractLink.setName(
                                yourNameController.text,
                              ); // [cite: 351]
                              yourNameController.clear(); // [cite: 364]
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
