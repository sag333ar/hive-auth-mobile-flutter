import 'package:flutter/material.dart';
import 'package:hiveauthsigner/socket/account_auth.dart';

class AuthDialogScreen extends StatefulWidget {
  const AuthDialogScreen({
    super.key,
    required this.payload,
  });

  final AuthReqDecryptedPayload payload;

  @override
  State<AuthDialogScreen> createState() => _AuthDialogScreenState();
}

class _AuthDialogScreenState extends State<AuthDialogScreen> {
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
          subtitle: const Text('Authenticate Action'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: Image.network(widget.payload.app.icon),
              title: Text(widget.payload.app.name),
              subtitle: Text(widget.payload.app.description),
              trailing: Text(widget.payload.challenge.keyType),
            ),
            SingleChildScrollView(
              child: Text(
                widget.payload.challenge.challenge
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => {},
              child: const Icon(Icons.check),
            ),
            const SizedBox(width: 40),
            FloatingActionButton(
              onPressed: () => {},
              child: const Icon(Icons.cancel),
            ),
          ]
      ),
    );
  }
}
