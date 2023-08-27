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
      final pinHashFile = await MethodChannelBiometricStorage().getStorage(_pinHash);
      final pinHashValue = await pinHashFile.read(promptInfo: const PromptInfo());
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
    final pinHashFile = await MethodChannelBiometricStorage().getStorage(_pinHash);
    await pinHashFile.write(value, promptInfo: const PromptInfo());
  }
}