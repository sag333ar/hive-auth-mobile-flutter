import 'dart:async';

import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/socket/socket_handler.dart';
import 'package:hiveauthsigner/utilities/storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

class HiveAuthData {
  SocketHandler handler = SocketHandler();
  late WebSocketChannel socket;

  HASPinStorageManager pinStorageManager = HASPinStorageManager();

  final themeColor = Colors.red[900];

  String userOwnerThumb(String value) {
    return "https://images.hive.blog/u/$value/avatar";
  }

  String communityIcon(String value) {
    return "https://images.hive.blog/u/$value/avatar?size=icon";
  }

  String resizedImage(String value) {
    return "https://images.hive.blog/640x320/$value";
  }

  // HiveAuth Signer Data
  final _hiveAuthSignerDataController = StreamController<HiveAuthSignerData>();

  Stream<HiveAuthSignerData> get hiveAuthSignerData {
    return _hiveAuthSignerDataController.stream;
  }

  void updateHiveUserData(HiveAuthSignerData data) {
    _hiveAuthSignerDataController.sink.add(data);
  }

  void setDarkMode(bool value, HiveAuthSignerData data) {
    updateHiveUserData(
      HiveAuthSignerData(
        doWeHaveSecurePin: data.doWeHaveSecurePin,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: value,
        mp: data.mp,
      ),
    );
  }

  void setLockUnlockApp(bool value, HiveAuthSignerData data) {
    updateHiveUserData(
      HiveAuthSignerData(
        doWeHaveSecurePin: data.doWeHaveSecurePin,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: value,
        hasWsServer: data.hasWsServer,
        isDarkMode: data.isDarkMode,
        mp: data.mp,
      ),
    );
  }

  void setPin(bool isPinSet, HiveAuthSignerData data) {
    updateHiveUserData(
      HiveAuthSignerData(
        doWeHaveSecurePin: isPinSet,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: data.isDarkMode,
        mp: data.mp,
      ),
    );
  }

  void setMp(String mp, HiveAuthSignerData data) {
    updateHiveUserData(
      HiveAuthSignerData(
        doWeHaveSecurePin: data.doWeHaveSecurePin,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: data.isDarkMode,
        mp: mp,
      ),
    );
  }

  void startSocket(String hasWsServer) {
    socket = WebSocketChannel.connect(
      Uri.parse(hasWsServer),
    );
    socket.stream.listen((message) {
      handler.handleMessage(message, socket);
    });
  }
}

HiveAuthData hiveAuthData = HiveAuthData();
