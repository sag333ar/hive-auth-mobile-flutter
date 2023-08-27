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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _drawerHeader(),
          _changeTheme(),
        ],
      ),
    );
  }
}
