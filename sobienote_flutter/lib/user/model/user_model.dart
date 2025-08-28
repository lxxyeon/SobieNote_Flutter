import 'package:json_annotation/json_annotation.dart';
import 'package:sobienote_flutter/user/request/social_login_request.dart';

part 'user_model.g.dart';

enum Gender {
  FEMALE('여자'),
  MALE('남자');

  final String label;

  const Gender(this.label);

  static Gender? fromJson(String? value) {
    if (value == null) return null;
    return Gender.values.firstWhere(
          (e) => e.label == value,
      orElse: () => throw ArgumentError('Invalid gender: $value'),
    );
  }

  String toJson() => label;
}

abstract class UserModelBase {}

class UserModelError extends UserModelBase {
  final String message;

  UserModelError({required this.message});
}

class UserModelLoading extends UserModelBase {}

@JsonSerializable()
class UserModel extends UserModelBase {
  final String email;
  final SocialType type;
  final String nickName;
  final String? name;
  final String? age;
  final String? school;
  final Gender? gender;

  UserModel({
    required this.email,
    required this.type,
    required this.nickName,
    this.name,
    this.age,
    this.school,
    this.gender
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
