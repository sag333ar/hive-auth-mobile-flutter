import 'dart:convert';

import 'package:biometricx/biometricx.dart';

import 'package:encryptor/encryptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hiveauthsigner/socket/account_auth.dart';
import 'package:hiveauthsigner/socket/signer_keys.dart';

class HASPinStorageManager {
  final String _appPin = 'app_pin';
  // final String _doWeHaveSecurePin = 'do_we_have_secure_pin';
  final String _appKeys = 'app_keys';
  final String _sessions = "sessions";
  final _storage = const FlutterSecureStorage();

  Future<bool> hasBiometrics() async {
    bool isBiometricEnabled = await BiometricX.isEnabled;
    return isBiometricEnabled;
  }

  Future<bool> doWeHaveSecurePinStored() async {
    String? appPinMessageKey = await _storage.read(key: _appPin);
    return appPinMessageKey != null;
  }

  Future<bool> validatePin(String value) async {
    String? appPinMessageKey = await _storage.read(key: _appPin);
    if (appPinMessageKey == null) {
      return false;
    }
    BiometricResult result = await BiometricX.decrypt(
      biometricKey: _appPin,
      messageKey: appPinMessageKey,
      title: 'Authenticate',
      subtitle: 'Enter biometric credentials to read PIN',
    );

    if (result.isSuccess && result.hasData) {
      String originalMessage = result.data!;
      return originalMessage == value;
    } else {
      return false;
    }
  }

  Future<void> setSecurePin(String value) async {
    BiometricResult result = await BiometricX.encrypt(
      biometricKey: _appPin,
      message: value,
      title: 'Authenticate',
      subtitle: 'Enter biometric credentials to save PIN',
    );
    if (result.isSuccess && result.hasData) {
      String messageKey = result.data!;
      await _storage.write(key: _appPin, value: messageKey);
    }
  }

  Future<List<SignerKeysModel>> getKeys(String mp) async {
    String value = await _storage.read(key: _appKeys) ?? "";
    if (value.isEmpty) {
      return [];
    }
    try {
      var decrypted = Encryptor.decrypt(mp, value);
      return SignerKeysModel.fromRawJson(decrypted);
    } catch (e) {
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
    var string = json.encode(auths.map((e) => e.toJson()).toList());
    await _storage.write(key: _sessions, value: string);
  }
}
