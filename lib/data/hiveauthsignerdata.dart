import 'package:web_socket_channel/web_socket_channel.dart';

class HiveAuthSignerData {
  String? appPinHash;
  bool dataLoaded;
  bool isAppUnlocked;
  String hasWsServer;
  bool isDarkMode;
  WebSocketChannel? webSocket;
  HiveAuthSignerData({
    required this.appPinHash,
    required this.dataLoaded,
    required this.isAppUnlocked,
    required this.hasWsServer,
    required this.isDarkMode,
    required this.webSocket,
  });
}