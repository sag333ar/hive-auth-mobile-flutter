import 'dart:core';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'dart:convert';

import 'package:hiveauthsigner/socket/account_auth.dart';
import 'package:hiveauthsigner/socket/bridge_response.dart';
import 'package:hiveauthsigner/socket/signer_keys.dart';

class SocketHandler {
  double hasProtocol = 0.0;
  String? keyServer;
  static const appName = "HiveAuth Signer Mobile App";
  List<AccountAuthModel> authModel = [];

  // List<SignerKeysModel> keys = [];
  static const keyTypes = ["memo", "posting", "active"];
  static const platform = MethodChannel('com.hiveauth.hiveauthsigner/bridge');
  AuthReqPayload? authReqPayload;
  Function? sendMessageHandler;

  String? getPrivateKey(String name, String type, List<SignerKeysModel> keys) {
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

  LowestPrivateKey? getLowestPrivateKey(
      String name, List<SignerKeysModel> keys) {
    for (var keyType in keyTypes) {
      var keyPrivate = getPrivateKey(name, keyType, keys);
      if (keyPrivate != null) {
        return LowestPrivateKey(keyType: keyType, keyPrivate: keyPrivate);
      } else {
        continue;
      }
    }
    return null;
  }

  Future<String?> getProofOfKey(
      String name, String? value, List<SignerKeysModel> keys) async {
    value ??= DateTime.now().toIso8601String();
    LowestPrivateKey? key = getLowestPrivateKey(name, keys);
    if (key != null && keyServer != null) {
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

  void handleMessage(
    String message,
    List<SignerKeysModel> keys,
    AuthReqPayload? authReqPayload,
    Function? handleKeysAck,
    Function? showAuthReqDialog,
    Function? sendMessage,
  ) {
    this.authReqPayload = authReqPayload;
    sendMessageHandler = sendMessage;
    if (kDebugMode) {
      log('Message received on socket - $message');
    }
    try {
      var payload = json.decode(message) as Map<String, dynamic>;
      var cmd = payload["cmd"] as String?;
      if (cmd != null) {
        switch (cmd) {
          case "connected":
            hasProtocol = (payload["protocol"] as double?) ?? 0;
            _handleConnected();
            break;
          case "error":
            log('Error occurred on websocket - $message');
            return;
          case "key_ack":
            if (handleKeysAck != null) {
              handleKeysAck();
            }
            if (keys.isNotEmpty) {
              _handleKeyAck(payload, keys);
            }
            return;
          case "register_ack":
            log('register is acknowledged on websocket - $message');
            break;
          case "auth_req":
            log('do something for "auth_req" - $message');
            _handleAuthReq(
              message,
              keys,
              handleKeysAck,
              payload,
              showAuthReqDialog,
            );
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

  void _handleAuthReq(
    String message,
    List<SignerKeysModel> newKeys,
    Function? handleKeysAck,
    Map<String, dynamic> payload,
    Function? showAuthReqDialog,
  ) async {
    var accountText = payload["account"] as String?;
    if (accountText == null) {
      return;
    }
    var payloadDataText = payload["data"] as String?;
    if (payloadDataText == null) {
      return;
    }
    var account = newKeys.firstWhereOrNull((element) =>
        accountText.trim().toLowerCase() == element.name.trim().toLowerCase());
    if (account == null) {
      return;
    }
    var authReqSecret = dotenv.env['AUTH_REQ_SECRET'];
    if (authReqSecret == null) {
      return;
    }
    var payloadAuthKey = payload["auth_key"] as String?;
    // load accountAuths & get accountAuths for this accountAuths request
    var auths = await hiveAuthData.pinStorageManager.getAuths();
    authModel = auths;
    var accountAuths = auths
        .where((e) =>
            e.name.trim().toLowerCase() == accountText.trim().toLowerCase())
        .toList()
        .firstOrNull;
    // if the auth_key was not provided by the app, check if we store any non-expired auth_key that can decrypt the auth_req_data
    if (payloadAuthKey == null && accountAuths != null) {
      for (var i = 0; i < accountAuths.auths.length; i++) {
        var expire = accountAuths.auths[i].ts_expire;
        var expireDate = DateTime.parse(expire);
        if (expireDate.compareTo(DateTime.now()) == -1) {
          final String response = await platform.invokeMethod('decrypt', {
            'data': payloadDataText,
            'key': accountAuths.auths[i].key,
          });
          var bridgeResponse = HasBridgeResponse.fromJsonString(response);
          if (bridgeResponse.data.isNotEmpty) {
            payloadAuthKey = accountAuths.auths[i].key;
            break;
          }
        }
      }
    }
    if (payloadAuthKey == null &&
        accountAuths == null &&
        authReqPayload != null) {
      final String response = await platform.invokeMethod('decrypt', {
        'data': payloadDataText,
        'key': authReqPayload!.key,
      });
      var bridgeResponse = HasBridgeResponse.fromJsonString(response);
      if (bridgeResponse.data.isNotEmpty && showAuthReqDialog != null) {
        showAuthReqDialog(bridgeResponse.data);
        return;
      }
    }
    if (payloadAuthKey == null) {
      return;
    }
    var authTimeout =
        (int.tryParse(dotenv.env['AUTH_TIMEOUT_DAYS'] ?? "30") ?? 30) *
            24 *
            60 *
            60 *
            1000;
    final String response = await platform.invokeMethod('decrypt', {
      'data': payloadDataText,
      'key': payloadAuthKey,
    });
    var bridgeResponse = HasBridgeResponse.fromJsonString(response);
    if (bridgeResponse.error.isNotEmpty || bridgeResponse.data.isEmpty) {
      return;
    }
    var authReqDataString = bridgeResponse.data;
    var authReqData = json.decode(authReqDataString);
    if (authReqData == null) {
      return;
    }
    Map<String, dynamic> authAckData = {};
    var approve = true;
    // Check if the matching auth it's still valid
    // const validAuth = account.auths.find(o => o.key==auth_key && o.expire > Date.now())
    AccountAuth? validAuth;
    var now = DateTime.now().millisecondsSinceEpoch;
    if (accountAuths != null) {
      for (var i = 0; i < accountAuths.auths.length; i++) {
        var expire = accountAuths.auths[i].expire;
        if (expire > now) {
          if (payloadAuthKey == accountAuths.auths[i].key) {
            validAuth = accountAuths.auths[i];
            break;
          }
        }
      }
    }

    if (validAuth != null) {
      authAckData['expire'] = validAuth.expire;
      approve = true;
    } else {
      authAckData['expire'] =
          DateTime.now().microsecondsSinceEpoch + authTimeout;
    }

    // Check if the app also requires the PKSA to sign a challenge
    var challenge = authReqData["challenge"] as Map<String, dynamic>?;
    var challengeKeyType = challenge?["key_type"] as String?;
    var challengeString = challenge?["challenge"] as String?;
    if (challenge != null &&
        challengeKeyType != null &&
        challengeString != null) {
      if (!keyTypes.contains(challengeKeyType)) {
        return;
      }
      var keyPrivate = getPrivateKey(
          accountText.trim().toLowerCase(), challengeKeyType, newKeys);

      final String signChallengeResponse =
          await platform.invokeMethod('signChallenge', {
        'challenge': challengeString,
        'key': keyPrivate,
      });
      var bridgeResponse =
          HasBridgeResponse.fromJsonString(signChallengeResponse);
      if (bridgeResponse.error.isNotEmpty) {
        return;
      }
      if (bridgeResponse.data.isEmpty) {
        return;
      }
      var pubKey = bridgeResponse.data.split("___")[0];
      var signHex = bridgeResponse.data.split("___")[1];
      authAckData["challenge"] = {'pubkey': pubKey, 'challenge': signHex};
    }
  }

  void _handleKeyAck(
    Map<String, dynamic> payload,
    List<SignerKeysModel> keys,
  ) async {
    keyServer = payload["key"] as String?;
    if (keyServer != null) {
      List<AccountAndProofOfKey> newAccounts = [];
      for (var element in keys) {
        var name = element.name.trim().toLowerCase();
        var proofOfKey = await getProofOfKey(name, null, keys);
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
      hasSend(jsonString);
    }
  }

  void _handleConnected() {
    hasSend(json.encode({"cmd": "key_req"}));
  }

  void hasSend(String message) {
    if (kDebugMode) {
      log('Sending message via socket - $message');
    }
    if (sendMessageHandler != null) {
      sendMessageHandler!(message);
    }
    // socket.sink.add(message);
  }
}
