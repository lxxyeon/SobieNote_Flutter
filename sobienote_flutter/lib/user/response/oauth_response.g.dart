// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthResponse _$OAuthResponseFromJson(Map<String, dynamic> json) =>
    OAuthResponse(
      accessToken: json['accessToken'] as String?,
      memberId: (json['memberId'] as num).toInt(),
    );

Map<String, dynamic> _$OAuthResponseToJson(OAuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'memberId': instance.memberId,
    };
