import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiveauthsigner/app/hiveauthsignerapp.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<void> _futureToLoadData;

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
            doWeHaveSecurePin: false,
            dataLoaded: false,
            isAppUnlocked: false,
            hasWsServer: "wss://hive-auth.arcange.eu",
            isDarkMode: true,
            mp: null,
            keyAck: false,
          ),
          child: const HiveAuthSignerApp(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _futureToLoadData = loadData();
  }

  Future<void> loadData() async {
    var hasWsServer = dotenv.env['HAS_SERVER'] ?? 'wss://hive-auth.arcange.eu';
    hiveAuthData.startSocket(hasWsServer, [], null);
    bool isPinStored =
        await hiveAuthData.pinStorageManager.doWeHaveSecurePinStored();
    hiveAuthData.updateHiveUserData(
      HiveAuthSignerData(
        doWeHaveSecurePin: isPinStored,
        dataLoaded: true,
        isAppUnlocked: false,
        hasWsServer: hasWsServer,
        isDarkMode: true,
        mp: null,
        keyAck: false,
      ),
    );
  }
}
