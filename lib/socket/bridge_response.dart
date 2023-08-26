import 'dart:convert';

class HasBridgeResponse {
  final String error;
  final String data;

  HasBridgeResponse({
    required this.error,
    required this.data,
  });

  factory HasBridgeResponse.fromJson(Map<String, dynamic>? json) =>
      HasBridgeResponse(
        error: json?['error'] as String? ?? '',
        data: json?['data'] as String? ?? '',
      );

  factory HasBridgeResponse.fromJsonString(String jsonString) =>
      HasBridgeResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
    'error': error,
    'data': data,
  };
}