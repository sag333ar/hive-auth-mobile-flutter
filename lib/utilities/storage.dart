import 'package:biometric_storage/biometric_storage.dart';

class HASPinStorageManager {
  final String _pinHash = 'app_pin_hash';

  Future<bool> hasBiometrics() async {
    final response = await MethodChannelBiometricStorage().canAuthenticate();
    if (response != CanAuthenticateResponse.success) {
      return false;
    } else {
      return true;
    }
  }

  Future<String?> appPinHash() async {
    try {
      final pinHashValue = await MethodChannelBiometricStorage().read(
          _pinHash, const PromptInfo());
      return pinHashValue;
    } catch (exception) {
      if (exception.toString().contains("Storage was not initialized $_pinHash")) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<void> updatePinHash(String value) async {
    await MethodChannelBiometricStorage().write(_pinHash, value, const PromptInfo());
  }
}