import 'dart:convert';

class AccountAuth {
  int expire;
  String key;
  String app;
  String? ts_create;
  String? ts_expire;
  String? ts_lastused;

  // double? nonce;

  AccountAuth({
    required this.expire,
    required this.key,
    required this.app,
    required this.ts_create,
    required this.ts_expire,
    required this.ts_lastused,
    // required this.nonce,
  });

  factory AccountAuth.fromJson(Map<String, dynamic> json) =>
      AccountAuth(
        expire: json['expire'],
        key: json['key'],
        app: json['app'],
        ts_create: json['ts_create'],
        ts_expire: json['ts_expire'],
        ts_lastused: json['ts_lastused'],
        // nonce: json['nonce'],
      );

  Map<String, dynamic> toJson() =>
      {
        'expire': expire,
        'key': key,
        'app': app,
        'ts_create': ts_create,
        'ts_expire': ts_expire,
        'ts_lastused': ts_lastused,
        // 'nonce': nonce,
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

  Map<String, dynamic> toJson() =>
      {
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

  factory AuthReqPayload.fromJson(Map<String, dynamic> json) =>
      AuthReqPayload(
        account: json["account"],
        uuid: json["uuid"],
        key: json["key"],
        host: json["host"],
      );

  Map<String, dynamic> toJson() =>
      {
        'account': account,
        'uuid': uuid,
        'key': key,
        'host': host,
      };
}

class AuthReqDecryptedPayloadApp {
  String name;
  String description;
  String icon;

  AuthReqDecryptedPayloadApp({
    required this.name,
    required this.description,
    required this.icon,
  });

  String toRawJson() => json.encode(toJson());

  factory AuthReqDecryptedPayloadApp.fromJsonString(String jsonString) =>
      AuthReqDecryptedPayloadApp.fromJson(json.decode(jsonString));

  factory AuthReqDecryptedPayloadApp.fromJson(Map<String, dynamic> json) =>
      AuthReqDecryptedPayloadApp(
        name: json["name"],
        description: json["description"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'description': description,
        'icon': icon,
      };
}

class AuthReqDecryptedPayloadChallenge {
  String keyType;
  String challenge;

  AuthReqDecryptedPayloadChallenge({
    required this.keyType,
    required this.challenge,
  });

  String toRawJson() => json.encode(toJson());

  factory AuthReqDecryptedPayloadChallenge.fromJsonString(String jsonString) =>
      AuthReqDecryptedPayloadChallenge.fromJson(json.decode(jsonString));

  factory AuthReqDecryptedPayloadChallenge.fromJson(
      Map<String, dynamic> json) =>
      AuthReqDecryptedPayloadChallenge(
        keyType: json["key_type"],
        challenge: json["challenge"],
      );

  Map<String, dynamic> toJson() =>
      {
        'key_type': keyType,
        'challenge': challenge,
      };
}

class AuthReqDecryptedPayload {
  AuthReqDecryptedPayloadChallenge challenge;
  AuthReqDecryptedPayloadApp app;

  AuthReqDecryptedPayload({
    required this.app,
    required this.challenge,
  });

  String toRawJson() => json.encode(toJson());

  factory AuthReqDecryptedPayload.fromJsonString(String jsonString) =>
      AuthReqDecryptedPayload.fromJson(json.decode(jsonString));

  factory AuthReqDecryptedPayload.fromJson(Map<String, dynamic> json) =>
      AuthReqDecryptedPayload(
        app: AuthReqDecryptedPayloadApp.fromJson(json["app"]),
        challenge: AuthReqDecryptedPayloadChallenge.fromJson(json["challenge"]),
      );

  Map<String, dynamic> toJson() =>
      {
        'app': app.toJson(),
        'challenge': challenge.toJson(),
      };
}
