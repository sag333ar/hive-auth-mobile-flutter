import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/screens/pinlock_screen.dart';
import 'package:provider/provider.dart';

class HiveAuthSignerApp extends StatelessWidget {
  const HiveAuthSignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<HiveAuthSignerData>(context);
    return MaterialApp(
      title: 'HiveAuth Signer',
      home: userData.dataLoaded
          ? PinLockScreen(data: userData)
          : Scaffold(
              appBar: AppBar(title: const Text('HiveAuth Signer')),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
      theme: userData.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
    );
  }
}
