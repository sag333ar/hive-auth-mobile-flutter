class HiveAuthSignerData {
  bool doWeHaveSecurePin;
  bool dataLoaded;
  bool isAppUnlocked;
  String hasWsServer;
  bool isDarkMode;
  String? mp;

  HiveAuthSignerData({
    required this.doWeHaveSecurePin,
    required this.dataLoaded,
    required this.isAppUnlocked,
    required this.hasWsServer,
    required this.isDarkMode,
    required this.mp,
  });
}