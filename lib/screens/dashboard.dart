import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/screens/about_screen.dart';
import 'package:hiveauthsigner/screens/import_keys.dart';
import 'package:hiveauthsigner/screens/manage_keys.dart';
import 'package:hiveauthsigner/screens/pinlock_screen.dart';
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

class _WelcomeScreenState extends State<WelcomeScreen> {
  var isDarkMode = false;
  var didSendInitialSocketRequest = false;
  var keyAck = false;

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

  Widget _scanQR() {
    return ListTile(
      leading: const Icon(Icons.qr_code),
      title: const Text("Scan QR Code"),
      onTap: () async {},
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
    defaultItems.add(_scanQR());
    defaultItems.add(_about());
    // defaultItems.add(_settings());
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

  void reconnectSockets(HiveAuthSignerData data) async {
    setState(() {
      didSendInitialSocketRequest = true;
    });
    if (data.mp != null) {
      setState(() {
        keyAck = false;
      });
      var ks = await hiveAuthData.pinStorageManager.getKeys(data.mp!);
      if (ks.isEmpty) {
        showMessage('No accounts found to connect');
      }
      setState(() {
        hiveAuthData.startSocket(data.hasWsServer, ks, () {
          setState(() {
            keyAck = true;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveAuthSignerData>(context);
    if (!didSendInitialSocketRequest) {
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
          reconnectSockets(data);
        },
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}
