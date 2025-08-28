// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
  name: json['name'] as String,
  email: json['email'] as String,
  type: $enumDecode(_$SocialTypeEnumMap, json['type']),
  schoolName: json['schoolName'] as String?,
  age: json['age'] as String?,
  studentName: json['studentName'] as String?,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
);

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'type': _$SocialTypeEnumMap[instance.type]!,
      'schoolName': instance.schoolName,
      'age': instance.age,
      'studentName': instance.studentName,
      'gender': instance.gender,
    };

const _$SocialTypeEnumMap = {
  SocialType.KAKAO: 'KAKAO',
  SocialType.GOOGLE: 'GOOGLE',
  SocialType.LOCAL: 'LOCAL',
};

const _$GenderEnumMap = {Gender.FEMALE: 'FEMALE', Gender.MALE: 'MALE'};
