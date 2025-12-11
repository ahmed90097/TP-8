import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";
  final String _privateKey =
      "0x06ce364c34ec0a532648edc70882d20743aea5efe762e7bd4eae0d33e6eeb864";

  late Web3Client _client;
  bool isLoading = true;

  late String _abiCode;
  late EthereumAddress _contractAddress;

  late Credentials _credentials;
  late DeployedContract _contract;
  late ContractFunction _yourName;
  late ContractFunction _setName;

  String deployedName = "";

  // CORRECTION ICI : On utilise BigInt pour le Chain ID
  late BigInt _chainId;

  ContractLinking() {
    initialSetup();
  }

  Future<void> initialSetup() async {
    _client = Web3Client(
      _rpcUrl,
      Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
    );

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile = await rootBundle.loadString("src/artifacts/HelloWorld.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    // Choisir dynamiquement le réseau présent dans le JSON (évite l'hardcode 5777/1337)
    if (jsonAbi["networks"] != null && jsonAbi["networks"].isNotEmpty) {
      var networks = jsonAbi["networks"] as Map<String, dynamic>;
      var firstNetwork = networks.keys.first;
      _contractAddress = EthereumAddress.fromHex(networks[firstNetwork]["address"]);
    } else {
      throw Exception("Aucune adresse de contrat trouvée dans l'ABI (networks)");
    }
  }

  Future<void> getCredentials() async {
    _credentials = await _client.credentialsFromPrivateKey(_privateKey);

    // CORRECTION ICI : On récupère le ChainID (1337 souvent) et non le NetworkID (5777)
    _chainId = await _client.getChainId();
    print("Chain ID réel utilisé pour la signature : $_chainId");
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
      ContractAbi.fromJson(_abiCode, "HelloWorld"),
      _contractAddress,
    );
    _yourName = _contract.function("yourName");
    _setName = _contract.function("setName");
    getName();
  }

  Future<void> getName() async {
    try {
      var currentName = await _client.call(
        contract: _contract,
        function: _yourName,
        params: [],
      );
      // Convertir le résultat en string de manière sécurisée
      if (currentName != null && currentName.isNotEmpty) {
        var result = currentName[0];
        deployedName = result is String ? result : result.toString();
      } else {
        deployedName = "Unknown";
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la lecture du nom: $e");
      deployedName = "Unknown";
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setName(String nameToSet) async {
    isLoading = true;
    notifyListeners();

    try {
      // Vérifier le solde du compte avant d'envoyer la transaction
      EthereumAddress fromAddress = await _credentials.extractAddress();
      EtherAmount balance = await _client.getBalance(fromAddress);
      final minRequired = EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.from(1000));
      if (balance.getInWei < minRequired.getInWei) {
        print("Solde insuffisant pour envoyer la transaction: ${balance.getInWei}");
        isLoading = false;
        notifyListeners();
        return;
      }

      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _setName,
          parameters: [nameToSet],
        ),
        chainId: _chainId.toInt(), // Conversion nécessaire ici
      );
    } catch (e) {
      print("Erreur lors de l'envoi de la transaction: $e");
    }

    await getName();
  }
}
