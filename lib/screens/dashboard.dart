import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
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

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.data.isDarkMode;
  }

  Widget _drawerHeader() {
    return DrawerHeader(
      child: InkWell(
        child: Column(
          children: [
            Image.asset(
              "assets/app-icon.png",
              height: 65,
            ),
            const SizedBox(height: 5),
            Text(
              "Auth Signer",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            Text(
              "@arcange, @sagarkothari88",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _changeTheme() {
    return ListTile(
      leading: !isDarkMode
          ? const Icon(Icons.wb_sunny)
          : const Icon(Icons.mode_night),
      title: const Text("Change Theme"),
      onTap: () async {
        hiveAuthData.setDarkMode(!widget.data.isDarkMode, widget.data);
        setState(() {
          isDarkMode = !widget.data.isDarkMode;
        });
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
      onTap: () async {},
    );
  }

  Widget _settings() {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text("Settings"),
      onTap: () async {},
    );
  }

  Widget _dashboardMenu() {
    List<Widget> defaultItems = [];
    defaultItems.add(_viewAccounts());
    defaultItems.add(_manageKeys());
    defaultItems.add(_import());
    defaultItems.add(_scanQR());
    defaultItems.add(_about());
    defaultItems.add(_settings());
    defaultItems.add(_changeTheme());
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

  void reconnectSockets(HiveAuthSignerData data) async {
    setState(() {
      didSendInitialSocketRequest = true;
    });
    if (data.mp != null) {
      var ks = await hiveAuthData.pinStorageManager.getKeys(data.mp!);
      hiveAuthData.startSocket(widget.data.hasWsServer, ks);
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveAuthSignerData>(context);
    if (didSendInitialSocketRequest) {
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
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              var screen = PinLockScreen(data: widget.data);
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).pushReplacement(route);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _dashboardMenu(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          reconnectSockets(data);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}