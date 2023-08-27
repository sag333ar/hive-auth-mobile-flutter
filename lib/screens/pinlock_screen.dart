import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/screens/drawer_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({
    super.key,
    required this.data,
  });

  final HiveAuthSignerData data;

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  var doWeHavePin = false;

  @override
  void initState() {
    super.initState();
    doWeHavePin = !(widget.data.appPinHash == null);
  }

  @override
  Widget build(BuildContext context) {
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
          subtitle: const Text('Pin Unlock'),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hello World!',
            ),
          ],
        ),
      ),
      drawer: DrawerScreen(data: widget.data),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          hiveAuthData.startSocket(widget.data.hasWsServer);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
