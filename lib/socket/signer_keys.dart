import 'dart:convert';

class SignerKeysModel {
  String name;

  String? posting;
  String? active;
  String? memo;

  SignerKeysModel({
    required this.name,
    required this.posting,
    required this.active,
    required this.memo,
  });

  static List<SignerKeysModel> fromRawJson(String str) {
    var result = json.decode(str) as List<dynamic>;
    return result.map((element) {
      return SignerKeysModel.fromJson(element);
    }).toList();
  }

  String toRawJson() => json.encode(toJson());

  factory SignerKeysModel.fromJson(Map<String, dynamic> json) =>
      SignerKeysModel(
        name: json["name"],
        posting: json["posting"],
        active: json["active"],
        memo: json["memo"],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'posting': posting,
        'active': active,
        'memo': memo,
      };
}

class LowestPrivateKey {
  String keyType;
  String keyPrivate;

  LowestPrivateKey({
    required this.keyType,
    required this.keyPrivate,
  });
}

class AccountAndProofOfKey {
  String name;
  String pok;

  AccountAndProofOfKey({
    required this.name,
    required this.pok,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'pok': pok,
      };
}

class RegisterRequest {
  String cmd;
  String app;
  List<AccountAndProofOfKey> accounts;

  RegisterRequest({
    required this.cmd,
    required this.app,
    required this.accounts,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> value = {
      'cmd': cmd,
      'app': app,
    };
    if (accounts.isNotEmpty) {
      var accountsValue = accounts.map((e) => e.toJson()).toList();
      value['accounts'] = accountsValue;
    }
    return value;
  }
}
