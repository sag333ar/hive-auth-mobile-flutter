import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/socket/signer_keys.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ManageKeysScreen extends StatefulWidget {
  const ManageKeysScreen({
    super.key,
  });

  @override
  State<ManageKeysScreen> createState() => _ManageKeysScreenState();
}

class _ManageKeysScreenState extends State<ManageKeysScreen> {
  var loadingKeys = false;
  List<SignerKeysModel>? keys;

  void loadKeys(String key) async {
    setState(() {
      loadingKeys = true;
    });
    var ks = await hiveAuthData.pinStorageManager.getKeys(key);
    setState(() {
      keys = ks;
      loadingKeys = false;
    });
  }

  Widget _loading() {
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(),
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

  Widget _list(HiveAuthSignerData data) {
    if (keys == null) {
      if (data.mp != null) {
        loadKeys(data.mp!);
      }
      return const Center(
        child: Text('loading Keys'),
      );
    }
    if (keys!.isEmpty) {
      return const Center(
        child: Text('No Keys found.'),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: ListView.separated(
        itemBuilder: (c, i) {
          var accountKeys = [
            keys![i].active != null ? 'active 🔑' : null,
            keys![i].posting != null ? 'posting 🔑' : null,
            keys![i].memo != null ? 'memo 🔑' : null,
          ].whereNotNull().toList().join(" · ");
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: Image.network(
                  hiveAuthData.userOwnerThumb(keys![i].name),
                  height: 40,
                  width: 40,
                ),
              ),
            ),
            title: Text(keys![i].name),
            subtitle: Text(accountKeys),
          );
        },
        separatorBuilder: (c, i) => const Divider(),
        itemCount: keys!.length,
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
          subtitle: const Text('Manage Keys'),
        ),
      ),
      body: (data.mp != null)
          ? loadingKeys
              ? _loading()
              : _list(data)
          : const Center(
              child: Text('Please lock & unlock app.'),
            ),
    );
  }
}
