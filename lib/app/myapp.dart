import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hiveauthsigner/app/hiveauthsignerapp.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<void> _futureToLoadData;
  late WebSocketChannel socket;

  Widget futureBuilder(Widget withWidget) {
    return FutureBuilder(
      future: _futureToLoadData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            title: 'HiveAuth Signer',
            home: Scaffold(
              appBar: AppBar(title: const Text('HiveAuth Signer')),
              body: const Center(
                child: Text('HiveAuth Signer not initialized'),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return withWidget;
        } else {
          return MaterialApp(
            title: 'HiveAuth Signer',
            home: Scaffold(
              appBar: AppBar(title: const Text('HiveAuth Signer')),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: futureBuilder(
        StreamProvider<HiveAuthSignerData>.value(
          value: hiveAuthData.hiveAuthSignerData,
          initialData: HiveAuthSignerData(
            appPinHash: null,
            dataLoaded: false,
            isAppUnlocked: false,
            hasWsServer: "wss://hive-auth.arcange.eu",
            isDarkMode: true,
          ),
          child: const HiveAuthSignerApp(),
        ),
      ),
    );
  }

  void startSocket(String hasWsServer) {
    socket = WebSocketChannel.connect(
      Uri.parse(hasWsServer),
    );
    socket.stream.listen((message) {
      log('Message received - $message');
    });
  }

  @override
  void initState() {
    super.initState();
    _futureToLoadData = loadData();
  }

  Future<void> loadData() async {
    var hasWsServer = dotenv.env['HAS_SERVER'] ?? 'wss://hive-auth.arcange.eu';
    startSocket(hasWsServer);
    const storage = FlutterSecureStorage();
    String? appPinHash = await storage.read(key: 'app_pin_hash');
    hiveAuthData.updateHiveUserData(
      HiveAuthSignerData(
        appPinHash: appPinHash,
        dataLoaded: true,
        isAppUnlocked: false,
        hasWsServer: hasWsServer,
        isDarkMode: true,
      ),
    );
  }
}