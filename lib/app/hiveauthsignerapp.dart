import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/screens/pinlock_screen.dart';
import 'package:provider/provider.dart';

class HiveAuthSignerApp extends StatelessWidget {
  const HiveAuthSignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<HiveAuthSignerData>(context);
    var lightTheme = ThemeData.light().copyWith(
      // colorScheme: ColorScheme.fromSeed(seedColor: hiveAuthData.themeColor),
      primaryColor: hiveAuthData.themeColor,
      primaryColorDark: hiveAuthData.themeColor,
      primaryColorLight: hiveAuthData.themeColor,
      appBarTheme: AppBarTheme(
        color: hiveAuthData.themeColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: hiveAuthData.themeColor,
      ),
    );
    var darkTheme = ThemeData.dark().copyWith(
      // colorScheme: ColorScheme.fromSeed(seedColor: hiveAuthData.themeColor),
      primaryColor: hiveAuthData.themeColor,
      primaryColorDark: hiveAuthData.themeColor,
      primaryColorLight: hiveAuthData.themeColor,
      appBarTheme: AppBarTheme(
        color: hiveAuthData.themeColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: hiveAuthData.themeColor,
      ),
    );

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
      theme: userData.isDarkMode ? darkTheme : lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
