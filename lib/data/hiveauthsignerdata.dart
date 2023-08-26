class HiveAuthSignerData {
  String? appPinHash;
  bool dataLoaded;
  bool isAppUnlocked;
  String hasWsServer;
  bool isDarkMode;

  HiveAuthSignerData({
    required this.appPinHash,
    required this.dataLoaded,
    required this.isAppUnlocked,
    required this.hasWsServer,
    required this.isDarkMode,
  });
}