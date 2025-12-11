import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour rootBundle
import 'package:http/http.dart'; // Pour Client()
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  // Configuration réseau (10.0.2.2 pour l'émulateur Android)
  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";

  // CLE PRIVÉE GANACHE (À CHANGER)
  final String _privateKey =
      "0xb6da238c1cc5309141f5bcd58d52a6d527576bfc34f1feee44ff9504f304a531"; //

  late Web3Client _client;
  bool isLoading = true;

  late String _abiCode;
  late EthereumAddress _contractAddress;

  late Credentials _credentials;
  late DeployedContract _contract;
  late ContractFunction _yourName;
  late ContractFunction _setName;

  String deployedName = ""; // [cite: 278]

  ContractLinking() {
    initialSetup(); // [cite: 290-292]
  }

  Future<void> initialSetup() async {
    // Initialisation du client Web3 avec HTTP et WebSocket
    _client = Web3Client(
      _rpcUrl,
      Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
    ); // [cite: 297-299]

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    // Chargement du fichier JSON
    String abiStringFile = await rootBundle.loadString(
      "src/artifacts/HelloWorld.json",
    ); // [cite: 306-307]
    var jsonAbi = jsonDecode(abiStringFile);

    _abiCode = jsonEncode(jsonAbi["abi"]); // [cite: 309]

    // Récupération de l'adresse du contrat (Network ID 5777 pour Ganache)
    _contractAddress = EthereumAddress.fromHex(
      jsonAbi["networks"]["5777"]["address"],
    ); // [cite: 311]
  }

  Future<void> getCredentials() async {
    _credentials = await _client.credentialsFromPrivateKey(
      _privateKey,
    ); // [cite: 314]
  }

  Future<void> getDeployedContract() async {
    // Création de l'objet contrat
    _contract = DeployedContract(
      ContractAbi.fromJson(_abiCode, "HelloWorld"),
      _contractAddress,
    ); // [cite: 317-320]

    // Récupération des fonctions
    _yourName = _contract.function("yourName"); // [cite: 322]
    _setName = _contract.function("setName"); // [cite: 323]

    // Appel initial pour récupérer le nom actuel
    getName(); // [cite: 324]
  }

  Future<void> getName() async {
    // Appel de la fonction de lecture (call)
    var currentName = await _client.call(
      contract: _contract,
      function: _yourName,
      params: [],
    ); // [cite: 328-329]

    deployedName = currentName[0];
    isLoading = false;
    notifyListeners(); // Mise à jour de l'UI [cite: 332]
  }

  Future<void> setName(String nameToSet) async {
    isLoading = true;
    notifyListeners();

    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _setName,
        parameters: [nameToSet],
      ),
      chainId:
          5777, // <--- AJOUTEZ CETTE LIGNE (C'est l'ID réseau de Ganache GUI)
    );

    getName();
  }
}
