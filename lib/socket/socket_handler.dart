import 'dart:developer';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class SocketHandler {
  double hasProtocol = 0.0;
  void handleMessage(String message, WebSocketChannel socket) {
    try {
      var payload = json.decode(message) as Map<String, dynamic>;
      var cmd = payload["cmd"] as String?;
      if (cmd != null) {
        switch (cmd) {
          case "connected":
            hasProtocol = (payload["protocol"] as double?) ?? 0;
            _handleConnected(socket);
            break;
          default:
            log("Received message on socket with cmd - $cmd - message - $message");
            break;
        }
      } else {
        log('CMD not found in socket message');
      }
    } catch (e) {
      log('Error occurred in socket handle message - ${e.toString()}');
    }
  }

  void _handleConnected(WebSocketChannel socket) {
    hasSend(json.encode({"cmd":"key_req"}), socket);
  }

  void hasSend(String message, WebSocketChannel socket) {
    log('Sending message via socket - $message');
    socket.sink.add(message);
  }
}