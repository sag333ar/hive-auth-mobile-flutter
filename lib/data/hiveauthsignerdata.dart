import 'package:hiveauthsigner/socket/account_auth.dart';

class HiveAuthSignerData {
  bool doWeHaveSecurePin;
  bool dataLoaded;
  bool isAppUnlocked;
  String hasWsServer;
  bool isDarkMode;
  String? mp;
  HASSocketData socketData;

  HiveAuthSignerData({
    required this.doWeHaveSecurePin,
    required this.dataLoaded,
    required this.isAppUnlocked,
    required this.hasWsServer,
    required this.isDarkMode,
    required this.mp,
    required this.socketData,
  });
}

class HASSocketData {
  bool wasKeyAcknowledged;
  AuthReqDecryptedPayload? actionPayload;

  HASSocketData({
    required this.wasKeyAcknowledged,
    required this.actionPayload,
  });
}
