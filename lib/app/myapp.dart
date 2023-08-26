import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
          return const Text('HiveAuth Signer not initialized');
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
            hasWsServer: "ws://hive-auth.arcange.eu",
            isDarkMode: true,
            webSocket: null,
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
    await dotenv.load(fileName: ".env");
    var hasWsServer = dotenv.env['HAS_SERVER'] ?? 'ws://hive-auth.arcange.eu';
    const storage = FlutterSecureStorage();
    String? appPinHash = await storage.read(key: 'app_pin_hash');
    hiveAuthData.updateHiveUserData(
      HiveAuthSignerData(
        appPinHash: appPinHash,
        dataLoaded: true,
        isAppUnlocked: false,
        hasWsServer: hasWsServer,
        isDarkMode: true,
        webSocket: null,
      ),
    );
  }
}
