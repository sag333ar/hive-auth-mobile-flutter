class AccountAuth {
  double expire;
  String key;
  String ts_create;
  String ts_expire;
  String? ts_lastused;
  double? nonce;

  AccountAuth({
    required this.expire,
    required this.key,
    required this.ts_create,
    required this.ts_expire,
    required this.ts_lastused,
    required this.nonce,
  });
}

class AccountAuthModel {
  String name;
  List<AccountAuth> auths;

  AccountAuthModel({
    required this.name,
    required this.auths,
  });
}