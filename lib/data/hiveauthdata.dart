import 'dart:async';

import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HiveAuthData {
  final String websocket = "https://3speak.tv";

  String userOwnerThumb(String value) {
    return "https://images.hive.blog/u/$value/avatar";
  }

  String userChannelCover(String value) {
    return "https://img.3speakcontent.co/user/$value/cover.png";
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
        appPinHash: data.appPinHash,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: value,
        webSocket: data.webSocket,
      ),
    );
  }

  void setWebSocket(WebSocketChannel socket, HiveAuthSignerData data) {
    updateHiveUserData(
      HiveAuthSignerData(
        appPinHash: data.appPinHash,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: data.isDarkMode,
        webSocket: socket,
      ),
    );
  }
}

HiveAuthData hiveAuthData = HiveAuthData();
