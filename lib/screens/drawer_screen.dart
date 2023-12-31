import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({
    super.key,
    required this.data,
  });

  final HiveAuthSignerData data;

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {

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
        onTap: () {
        },
      ),
    );
  }

  Widget _changeTheme() {
    return ListTile(
      leading: !widget.data.isDarkMode
          ? const Icon(Icons.wb_sunny)
          : const Icon(Icons.mode_night),
      title: const Text("Change Theme"),
      onTap: () async {
        hiveAuthData.setDarkMode(!widget.data.isDarkMode, widget.data);
      },
    );
  }

  Widget _viewAccounts() {
    return ListTile(
      leading: const Icon(Icons.group),
      title: const Text("View Accounts"),
      onTap: () async {

      },
    );
  }

  Widget _manageKeys() {
    return ListTile(
      leading: const Icon(Icons.key_sharp),
      title: const Text("Manage Keys"),
      onTap: () async {

      },
    );
  }

  Widget _import() {
    return ListTile(
      leading: const Icon(Icons.add_box_outlined),
      title: const Text("Import"),
      onTap: () async {

      },
    );
  }

  Widget _scanQR() {
    return ListTile(
      leading: const Icon(Icons.qr_code),
      title: const Text("Scan QR Code"),
      onTap: () async {

      },
    );
  }

  Widget _lock() {
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text("Lock App"),
      onTap: () async {

      },
    );
  }

  Widget _about() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text("About"),
      onTap: () async {

      },
    );
  }

  Widget _settings() {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text("Settings"),
      onTap: () async {

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var defaultItems = [
      _drawerHeader(),
      _changeTheme(),
    ];
    if (widget.data.isAppUnlocked == true) {
      defaultItems.add(_viewAccounts());
      defaultItems.add(_manageKeys());
      defaultItems.add(_import());
      defaultItems.add(_scanQR());
    }
    defaultItems.add(_about());
    defaultItems.add(_settings());
    if (widget.data.isAppUnlocked == true) {
      defaultItems.add(_lock());
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: defaultItems,
      ),
    );
  }
}
