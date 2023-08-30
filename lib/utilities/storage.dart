import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:encryptor/encryptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hiveauthsigner/socket/account_auth.dart';
import 'package:hiveauthsigner/socket/signer_keys.dart';

class HASPinStorageManager {
  final String _appPin = 'app_pin';
  final String _doWeHaveSecurePin = 'do_we_have_secure_pin';
  final String _appKeys = 'app_keys';
  final String _sessions = "sessions";
  final _storage = const FlutterSecureStorage();

  Future<bool> hasBiometrics() async {
    final response = await MethodChannelBiometricStorage().canAuthenticate();
    if (response != CanAuthenticateResponse.success) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> doWeHaveSecurePinStored() async {
    String value = await _storage.read(key: _doWeHaveSecurePin) ?? "";
    return value == "true";
  }

  Future<bool> validatePin(String value) async {
    try {
      final pinFile = await MethodChannelBiometricStorage().getStorage(_appPin);
      final pinValue = await pinFile.read(promptInfo: const PromptInfo());
      if (pinValue == null) {
        return false;
      }
      return pinValue == value;
    } catch (exception) {
      if (exception.toString().contains("Storage was not initialized $_appPin")) {
        return false;
      } else {
        rethrow;
      }
    }
  }

  Future<void> setSecurePin(String value) async {
    final pinHashFile = await MethodChannelBiometricStorage().getStorage(_appPin);
    await _storage.write(key: _doWeHaveSecurePin, value: 'true');
    await pinHashFile.write(value, promptInfo: const PromptInfo());
  }

  Future<List<SignerKeysModel>> getKeys(String mp) async {
    String value = await _storage.read(key: _appKeys) ?? "";
    if (value.isEmpty) {
      return [];
    }
    try {
      var decrypted = Encryptor.decrypt(mp, value);
      return SignerKeysModel.fromRawJson(decrypted);
    } catch(e) {
      return [];
    }
  }

  Future<void> updateKeys(String mp, List<SignerKeysModel> keys) async {
    var string = json.encode(keys);
    var encrypted = Encryptor.encrypt(mp, string);
    await _storage.write(key: _appKeys, value: encrypted);
  }

  Future<List<AccountAuthModel>> getAuths() async {
    String value = await _storage.read(key: _sessions) ?? "";
    if (value.isEmpty) {
      return [];
    }
    return AccountAuthModel.fromRawJson(value);
  }

  Future<void> updateAuths(List<AccountAuthModel> auths) async {
    var string = json.encode(auths);
    await _storage.write(key: _sessions, value: string);
  }
}