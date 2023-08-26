class SignerKeysModel {
  String name;

  String? posting;
  String? postingPublic;

  String? active;
  String? activePublic;

  String? memo;
  String? memoPublic;

  SignerKeysModel({
    required this.name,
    required this.posting,
    required this.postingPublic,
    required this.active,
    required this.activePublic,
    required this.memo,
    required this.memoPublic,
  });
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
