import 'package:json_annotation/json_annotation.dart';

part 'oauth_response.g.dart';

enum VerificationType {
  SIGNUP,
  RESET;
}

@JsonSerializable()
class OAuthResponse{
  final String? accessToken;
  final int memberId;

  OAuthResponse({required this.accessToken, required this.memberId});

  factory OAuthResponse.fromJson(Map<String, dynamic> json) => _$OAuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OAuthResponseToJson(this);
}