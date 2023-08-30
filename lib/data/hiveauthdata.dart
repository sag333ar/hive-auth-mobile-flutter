import 'dart:async';

import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/socket/account_auth.dart';
import 'package:hiveauthsigner/utilities/storage.dart';
import 'package:flutter/material.dart';

class HiveAuthData {
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
        socketData: data.socketData,
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
        socketData: data.socketData,
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
        socketData: data.socketData,
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
        socketData: data.socketData,
      ),
    );
  }

  void setKeyAck(bool value, HiveAuthSignerData data) {
    updateHiveUserData(
      HiveAuthSignerData(
        doWeHaveSecurePin: data.doWeHaveSecurePin,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: data.isDarkMode,
        mp: data.mp,
        socketData: HASSocketData(
          actionPayload: data.socketData.actionPayload,
          wasKeyAcknowledged: value,
        ),
      ),
    );
  }

  void setActionPayload(AuthReqDecryptedPayload? actionPayload, HiveAuthSignerData data) {
    updateHiveUserData(
      HiveAuthSignerData(
        doWeHaveSecurePin: data.doWeHaveSecurePin,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: data.isDarkMode,
        mp: data.mp,
        socketData: HASSocketData(
          actionPayload: actionPayload,
          wasKeyAcknowledged: data.socketData.wasKeyAcknowledged,
        ),
      ),
    );
  }

  // void startSocket(
  //   String hasWsServer,
  //   List<SignerKeysModel> newKeys,
  //   AuthReqPayload? authReqPayload,
  //   Function? handleKeysAck,
  //   Function? showAuthReqDialog,
  // ) {
  //   socket = WebSocketChannel.connect(
  //     Uri.parse(hasWsServer),
  //   );
  //   socket.stream.listen((message) {
  //     handler.handleMessage(
  //       message,
  //       socket,
  //       newKeys,
  //       authReqPayload,
  //       handleKeysAck,
  //       showAuthReqDialog,
  //     );
  //   });
  // }
}

HiveAuthData hiveAuthData = HiveAuthData();
