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
import 'package:hiveauthsigner/socket/socket_handler.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.data,
  });

  final HiveAuthSignerData data;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  var isDarkMode = false;
  WebSocketChannel? socket;

  // = WebSocketChannel.connect(
  //   Uri.parse('wss://hive-auth.arcange.eu'),
  // );
  SocketHandler handler = SocketHandler();
  AuthReqPayload? qrScannerAuthReqPayload;

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
              qrScannerAuthReqPayload = payload;
              reconnectSockets(data);
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

  void startSocket(String hasWsServer, HiveAuthSignerData data) {
    setState(() {
      if (socket != null) {
        socket?.sink.close();
        socket = null;
      }
      socket = WebSocketChannel.connect(
        Uri.parse(hasWsServer),
      );
    });
    socket?.stream.listen((event) {
      var string = event as String?;
      if (string != null) {
        handleMessage(string, data);
      }
    });
  }

  void reconnectSockets(HiveAuthSignerData data) async {
    startSocket(qrScannerAuthReqPayload?.host ?? data.hasWsServer, data);
  }

  void handleMessage(String message, HiveAuthSignerData data) async {
    var ks = await hiveAuthData.pinStorageManager.getKeys(data.mp!);
    handler.handleMessage(message, ks, qrScannerAuthReqPayload, () {
      hiveAuthData.setKeyAck(true, data);
    }, (authDataAsString) {
      var payload = AuthReqDecryptedPayload.fromJsonString(authDataAsString);
      hiveAuthData.setActionPayload(payload, data);
    }, (message) {
      socket?.sink.add(message);
    });
  }

  void showBottomDialog(
    AuthReqDecryptedPayload payload,
    HiveAuthSignerData data,
  ) {
    Future.delayed(const Duration(milliseconds: 1250), () {
      var screen = AuthDialogScreen(payload: payload);
      hiveAuthData.setActionPayload(null, data);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: screen,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var data = Provider.of<HiveAuthSignerData>(context);
    if (data.socketData.actionPayload != null) {
      showBottomDialog(data.socketData.actionPayload!, data);
    }
    if (socket == null) {
      reconnectSockets(data);
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
            color: data.socketData.wasKeyAcknowledged
                ? Colors.green
                : Colors.grey,
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
          reconnectSockets(data);
        },
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket?.sink.close();
    super.dispose();
  }
}
