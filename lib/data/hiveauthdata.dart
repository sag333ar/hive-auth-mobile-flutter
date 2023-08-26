import 'dart:async';

import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';

class HiveAuthData {
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
        appPinHash: data.appPinHash,
        dataLoaded: data.dataLoaded,
        isAppUnlocked: data.isAppUnlocked,
        hasWsServer: data.hasWsServer,
        isDarkMode: value,
      ),
    );
  }
}

HiveAuthData hiveAuthData = HiveAuthData();
