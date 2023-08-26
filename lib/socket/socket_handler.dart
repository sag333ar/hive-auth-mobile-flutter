import 'dart:core';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:hiveauthsigner/socket/account_auth.dart';
import 'package:hiveauthsigner/socket/bridge_response.dart';
import 'package:hiveauthsigner/socket/signer_keys.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketHandler {
  double hasProtocol = 0.0;
  String? keyServer;
  static const appName = "HiveAuth Signer Mobile App";
  List<AccountAuthModel> authModel = [];
  List<SignerKeysModel> keys = [];
  static const keyTypes = ["memo", "posting", "active"];

  String? getPrivateKey(String name, String type) {
    var account = keys
        .firstWhereOrNull((o) => o.name.toLowerCase() == name.toLowerCase());
    if (account != null) {
      switch (type) {
        case "posting":
          return account.posting;
        case "active":
          return account.active;
        case "memo":
          return account.memo;
        default:
          throw "invalid key type $type";
      }
    } else {
      return null;
    }
  }

  LowestPrivateKey? getLowestPrivateKey(String name) {
    for (var keyType in keyTypes) {
      var keyPrivate = getPrivateKey(name, keyType);
      if (keyPrivate != null) {
        return LowestPrivateKey(keyType: keyType, keyPrivate: keyPrivate);
      } else {
        continue;
      }
    }
    return null;
  }

  Future<String?> getProofOfKey(String name, String? value) async {
    value ??= DateTime.now().toIso8601String();
    LowestPrivateKey? key = getLowestPrivateKey(name);
    if (key != null && keyServer != null) {
      const platform = MethodChannel('com.hiveauth.hiveauthsigner/bridge');
      final String response = await platform.invokeMethod('getProofOfKey', {
        'privateKey': key.keyPrivate,
        'publicKey': keyServer,
        'memo': value,
      });
      var bridgeResponse = HasBridgeResponse.fromJsonString(response);
      if (bridgeResponse.error.isNotEmpty) {
        throw bridgeResponse.error;
      } else {
        return bridgeResponse.data;
      }
    } else {
      return null;
    }
  }

  void handleMessage(String message, WebSocketChannel socket) {
    // log('Message received on socket - $message');
    try {
      var payload = json.decode(message) as Map<String, dynamic>;
      var cmd = payload["cmd"] as String?;
      if (cmd != null) {
        switch (cmd) {
          case "connected":
            hasProtocol = (payload["protocol"] as double?) ?? 0;
            _handleConnected(socket);
            break;
          case "error":
            log('Error occurred on websocket - $message');
            return;
          case "key_ack":
            if (keys.isNotEmpty) {
              _handleKeyAck(payload, socket);
            }
            return;
          case "register_ack":
            log('register is acknowledged on websocket - $message');
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

  void _handleKeyAck(
    Map<String, dynamic> payload,
    WebSocketChannel socketChannel,
  ) async {
    keyServer = payload["key"] as String?;
    if (keyServer != null) {
      List<AccountAndProofOfKey> newAccounts = [];
      for (var element in keys) {
        var name = element.name.trim().toLowerCase();
        var proofOfKey = await getProofOfKey(name, null);
        if (name.isNotEmpty && proofOfKey != null && proofOfKey.isNotEmpty) {
          newAccounts.add(
            AccountAndProofOfKey(
              name: name,
              pok: proofOfKey,
            ),
          );
        }
      }
      var request = RegisterRequest(
        app: appName,
        cmd: "register_req",
        accounts: newAccounts,
      ).toJson();
      var jsonString = json.encode(request);
      hasSend(jsonString, socketChannel);
    }
  }

  void _handleConnected(WebSocketChannel socket) {
    hasSend(json.encode({"cmd": "key_req"}), socket);
  }

  void hasSend(String message, WebSocketChannel socket) {
    // log('Sending message via socket - $message');
    socket.sink.add(message);
  }
}
