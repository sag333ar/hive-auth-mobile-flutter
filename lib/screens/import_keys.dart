import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/socket/bridge_response.dart';
import 'package:hiveauthsigner/socket/signer_keys.dart';
import 'package:provider/provider.dart';

class ImportKeysScreen extends StatefulWidget {
  const ImportKeysScreen({super.key});

  @override
  State<ImportKeysScreen> createState() => _ImportKeysScreenState();
}

class _ImportKeysScreenState extends State<ImportKeysScreen> {
  var hiveUserName = '';
  var hiveKey = '';
  var checking = false;

  Widget _inputUserName() {
    return TextField(
      decoration: const InputDecoration(
        icon: Icon(Icons.person),
        label: Text('Hive Username'),
        hintText: 'Enter Hive Username here.',
      ),
      onChanged: (value) {
        setState(() {
          hiveUserName = value;
        });
      },
    );
  }

  Widget _inputKey() {
    return TextField(
      decoration: const InputDecoration(
        icon: Icon(Icons.key),
        label: Text('Private Key'),
        hintText: 'Enter Key (Active / Posting / Memo) here.',
      ),
      obscureText: true,
      onChanged: (value) {
        setState(() {
          hiveKey = value;
        });
      },
    );
  }

  Widget _form(HiveAuthSignerData data) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          children: [
            _inputUserName(),
            const SizedBox(height: 15),
            _inputKey(),
            const SizedBox(height: 15),
            _submitButton(data),
          ],
        ),
      ),
    );
  }

  void showError(String string) async {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) async {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void validateKey(HiveAuthSignerData data) async {
    setState(() {
      checking = true;
    });
    var enteredUserName = hiveUserName.trim().toLowerCase();
    var enteredKey = hiveKey.trim();
    const platform = MethodChannel('com.hiveauth.hiveauthsigner/bridge');
    final String response = await platform.invokeMethod('validateHiveKey', {
      'accountName': enteredUserName,
      'userKey': enteredKey,
    });
    var bridgeResponse = HasBridgeResponse.fromJsonString(response);
    if (bridgeResponse.error.isNotEmpty) {
      showError(bridgeResponse.error);
    } else if (bridgeResponse.data.isNotEmpty) {
      if (data.mp != null) {
        var existingKeys =
            await hiveAuthData.pinStorageManager.getKeys(data.mp!);
        var firstAccount = existingKeys
            .firstWhereOrNull((e) => e.name.toLowerCase() == enteredUserName);
        var didUpdate = false;
        var messageToShow = '';
        if (firstAccount == null) {
          if (bridgeResponse.data == 'posting') {
            existingKeys.add(
              SignerKeysModel(
                name: enteredUserName,
                posting: enteredKey,
                active: null,
                memo: null,
              ),
            );
            didUpdate = true;
            messageToShow =
                '$enteredUserName\'s private posting key was imported';
          } else if (bridgeResponse.data == 'active') {
            existingKeys.add(
              SignerKeysModel(
                name: enteredUserName,
                posting: null,
                active: enteredKey,
                memo: null,
              ),
            );
            didUpdate = true;
            messageToShow =
                '$enteredUserName\'s private active key was imported';
          } else if (bridgeResponse.data == 'memo') {
            existingKeys.add(
              SignerKeysModel(
                name: enteredUserName,
                posting: null,
                active: null,
                memo: enteredKey,
              ),
            );
            didUpdate = true;
            messageToShow = '$enteredUserName\'s private memo key was imported';
          } else {
            showError('Unknown key type found.');
          }
        } else {
          for (var i = 0; i < existingKeys.length; i++) {
            if (existingKeys[i].name.trim().toLowerCase() == enteredUserName) {
              if (bridgeResponse.data == 'posting') {
                existingKeys[i].posting = enteredKey;
                didUpdate = true;
                messageToShow =
                    '$enteredUserName\'s private posting key was imported';
              } else if (bridgeResponse.data == 'active') {
                existingKeys[i].active = enteredKey;
                didUpdate = true;
                messageToShow =
                    '$enteredUserName\'s private active key was imported';
              } else if (bridgeResponse.data == 'memo') {
                existingKeys[i].memo = enteredKey;
                didUpdate = true;
                messageToShow =
                    '$enteredUserName\'s private memo key was imported';
              } else {
                showError('Unknown key type found.');
              }
            }
          }
        }
        if (didUpdate && messageToShow.isNotEmpty) {
          await hiveAuthData.pinStorageManager
              .updateKeys(data.mp!, existingKeys);
          showMessage(messageToShow);
        }
      } else {
        showError('Please lock & unlock app.');
      }
    } else {
      showError('Something went wrong');
    }
    setState(() {
      checking = false;
    });
  }

  Widget _submitButton(HiveAuthSignerData data) {
    var enteredUserName = hiveUserName.trim().toLowerCase();
    var enteredKey = hiveKey.trim();
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.red[800]),
      ),
      onPressed: () async {
        if (enteredUserName.isEmpty) {
          showError('Please Enter valid hive username');
          return;
        }
        if (enteredKey.isEmpty) {
          showError('Please Enter valid hive private key');
          return;
        }
        validateKey(data);
      },
      child: const Text('Import Key'),
    );
  }

  Widget _loading() {
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveAuthSignerData>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: ListTile(
          leading: Image.asset(
            'assets/app-icon.png',
            width: 40,
            height: 40,
          ),
          title: const Text('Auth Signer'),
          subtitle: const Text('Import Keys'),
        ),
      ),
      body: checking ? _loading() : _form(data),
    );
  }
}
