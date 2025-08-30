import 'package:json_annotation/json_annotation.dart';
import 'package:sobienote_flutter/user/request/social_login_request.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  final String name;
  final String email;
  final SocialType type;
  final String? schoolName;
  final String? age;
  final String? studentName;
  final String? gender;

  UserResponse({
    required this.name,
    required this.email,
    required this.type,
    this.schoolName,
    this.age,
    this.studentName,
    this.gender
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}