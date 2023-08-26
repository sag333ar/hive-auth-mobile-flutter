import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({
    Key? key,
    required this.data,
  });

  final HiveAuthSignerData data;

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  @override
  void initState() {
    super.initState();
    listenToSocket();
  }

  void listenToSocket() {
    if (widget.data.webSocket != null) {
      WebSocketChannel socket = widget.data.webSocket!;
      socket.stream.listen((event) {
        log('Message received - $event');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('HiveAuth Signer'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.data.webSocket != null) {
            listenToSocket();
          } else {
            var newSocket = WebSocketChannel.connect(Uri.parse('ws://hive-auth.arcange.eu'));
            await newSocket.ready;
            hiveAuthData.setWebSocket(newSocket, widget.data);
            listenToSocket();
          }
        },
        child: const Text('Start Socket'),
      ),
    );
  }
}
