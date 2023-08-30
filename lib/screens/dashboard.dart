import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/screens/about_screen.dart';
import 'package:hiveauthsigner/screens/auth_dialog.dart';
import 'package:hiveauthsigner/screens/import_keys.dart';
import 'package:hiveauthsigner/screens/manage_keys.dart';
import 'package:hiveauthsigner/screens/pinlock_screen.dart';
import 'package:hiveauthsigner/screens/qr_scanner.dart';
import 'package:hiveauthsigner/socket/account_auth.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.data,
  });

  final HiveAuthSignerData data;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  var isDarkMode = false;
  var didSendInitialSocketRequest = false;
  var keyAck = false;
  AuthReqDecryptedPayload? payload;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.data.isDarkMode;
  }

  Widget _changeTheme(HiveAuthSignerData data) {
    return ListTile(
      leading: !data.isDarkMode
          ? const Icon(Icons.wb_sunny)
          : const Icon(Icons.mode_night),
      title: const Text("Change Theme"),
      onTap: () {
        hiveAuthData.setDarkMode(!data.isDarkMode, data);
      },
    );
  }

  Widget _viewAccounts() {
    return ListTile(
      leading: const Icon(Icons.group),
      title: const Text("View Accounts"),
      onTap: () async {},
    );
  }

  Widget _manageKeys() {
    return ListTile(
      leading: const Icon(Icons.key_sharp),
      title: const Text("Manage Keys"),
      onTap: () {
        var screen = const ManageKeysScreen();
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _import() {
    return ListTile(
      leading: const Icon(Icons.add_box_outlined),
      title: const Text("Import"),
      onTap: () {
        var screen = const ImportKeysScreen();
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _scanQR(HiveAuthSignerData data) {
    return ListTile(
      leading: const Icon(Icons.qr_code),
      title: const Text("Scan QR Code"),
      onTap: () {
        var screen = QRScannerScreen(didFinishScan: (scanText) {
          var text = scanText as String?;
          if (text != null &&
              text.isNotEmpty &&
              text.contains('has://auth_req/')) {
            var newText = text.split('has://auth_req/')[1];
            var decodedBytes = base64.decode(newText);
            var decodedStr = utf8.decode(decodedBytes);
            log('Decoded string is - $decodedStr');
            var payload = AuthReqPayload.fromJsonString(decodedStr);
            setState(() {
              reconnectSockets(data, payload);
            });
          }
          // payload.host
        });
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _lock() {
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text("Lock App"),
      onTap: () {
        hiveAuthData.setKeyAck(false, widget.data);
        var screen = PinLockScreen(data: widget.data);
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).pushReplacement(route);
      },
    );
  }

  Widget _about() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text("About"),
      onTap: () {
        var screen = const AboutScreen();
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _settings() {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text("Settings"),
      onTap: () async {},
    );
  }

  Widget _dashboardMenu(HiveAuthSignerData data) {
    List<Widget> defaultItems = [];
    // defaultItems.add(_viewAccounts());
    defaultItems.add(_manageKeys());
    defaultItems.add(_import());
    defaultItems.add(_scanQR(data));
    defaultItems.add(_about());
    defaultItems.add(_changeTheme(data));
    defaultItems.add(_lock());
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: ListView.separated(
        itemBuilder: (c, i) => defaultItems[i],
        separatorBuilder: (c, i) => const Divider(),
        itemCount: defaultItems.length,
      ),
    );
  }

  void showMessage(String string) async {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void reconnectSockets(
    HiveAuthSignerData data,
    AuthReqPayload? authReqPayload,
  ) async {
    if (mounted) {
      setState(() {
        didSendInitialSocketRequest = true;
      });
    }
    if (data.mp != null) {
      if (mounted) {
        setState(() {
          keyAck = false;
        });
      }
      var ks = await hiveAuthData.pinStorageManager.getKeys(data.mp!);
      if (ks.isEmpty) {
        showMessage('No accounts found to connect');
      }
      hiveAuthData.startSocket(
          authReqPayload?.host ?? data.hasWsServer, ks, authReqPayload, () {
        if (mounted) {
          setState(() {
            keyAck = true;
          });
        }
      }, (authDataAsString) {
        if (mounted) {
          setState(() {
            payload =
                AuthReqDecryptedPayload.fromJsonString(authDataAsString);
          });
        }
      });
    }
  }

  void showBottomDialog(AuthReqDecryptedPayload payload) {
    var screen = AuthDialogScreen(payload: payload);
    this.payload = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      builder: (context) {
        return SizedBox(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.4,
          child: screen,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (payload != null) {
      showBottomDialog(payload!);
    }
    var data = Provider.of<HiveAuthSignerData>(context);
    if (!didSendInitialSocketRequest) {
      reconnectSockets(data, null);
    }
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
          subtitle: const Text('Dashboard'),
        ),
        actions: [
          Icon(
            Icons.public,
            color: keyAck ? Colors.green : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              hiveAuthData.setKeyAck(false, widget.data);
              var screen = PinLockScreen(data: widget.data);
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).pushReplacement(route);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _dashboardMenu(data),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          reconnectSockets(data, null);
        },
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}
