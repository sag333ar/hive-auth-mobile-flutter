import 'dart:convert';

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

  factory AccountAuth.fromJson(Map<String, dynamic> json) => AccountAuth(
        expire: json['expire'],
        key: json['key'],
        ts_create: json['ts_create'],
        ts_expire: json['ts_expire'],
        ts_lastused: json['ts_lastused'],
        nonce: json['nonce'],
      );

  Map<String, dynamic> toJson() => {
        'expire': expire,
        'key': key,
        'ts_create': ts_create,
        'ts_expire': ts_expire,
        'ts_lastused': ts_lastused,
        'nonce': nonce,
      };
}

class AccountAuthModel {
  String name;
  List<AccountAuth> auths;

  AccountAuthModel({
    required this.name,
    required this.auths,
  });

  static List<AccountAuthModel> fromRawJson(String str) {
    var result = json.decode(str) as List<dynamic>;
    return result.map((element) {
      return AccountAuthModel.fromJson(element);
    }).toList();
  }

  String toRawJson() => json.encode(toJson());

  factory AccountAuthModel.fromJson(Map<String, dynamic> json) =>
      AccountAuthModel(
        name: json["name"],
        auths: (json["auths"] as List<Map<String, dynamic>>)
            .map((e) => AccountAuth.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'auths': auths.map((e) => e.toJson()),
      };
}

class AuthReqPayload {
  String account;
  String uuid;
  String key;
  String host;

  AuthReqPayload({
    required this.account,
    required this.uuid,
    required this.key,
    required this.host,
  });

  String toRawJson() => json.encode(toJson());

  factory AuthReqPayload.fromJsonString(String jsonString) =>
      AuthReqPayload.fromJson(json.decode(jsonString));

  factory AuthReqPayload.fromJson(Map<String, dynamic> json) => AuthReqPayload(
        account: json["account"],
        uuid: json["uuid"],
        key: json["key"],
        host: json["host"],
      );

  Map<String, dynamic> toJson() => {
        'account': account,
        'uuid': uuid,
        'key': key,
        'host': host,
      };
}
