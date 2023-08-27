import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/screens/drawer_screen.dart';

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
  Widget _menu() {
    List<Widget> defaultItems = [
      // _drawerHeader(),
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
      defaultItems.add(_changeTheme());
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: defaultItems,
    );
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
          title: const Text('Dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: _menu(),
      ),
      // drawer: DrawerScreen(data: widget.data),
    );
  }
}

/*
Column(
          children: [
            const Spacer(),
            Text(
              'Welcome to Hive Auth Signer.\nPlease choose an action.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.group),
                  label: const Text('View Accounts'),
                ),
                const SizedBox(width: 30),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.key),
                  label: const Text('Manage Keys'),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Import Keys'),
                ),
                const SizedBox(width: 30),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Scan QR Code'),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 30),
            const Spacer(),
          ],
        ),
 */
