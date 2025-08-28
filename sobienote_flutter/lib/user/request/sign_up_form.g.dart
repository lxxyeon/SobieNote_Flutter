// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpForm _$SignUpFormFromJson(Map<String, dynamic> json) => SignUpForm(
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  schoolName: json['schoolName'] as String?,
  age: (json['age'] as num?)?.toInt(),
  studentName: json['studentName'] as String?,
  gender: Gender.fromJson(json['gender'] as String?),
);

Map<String, dynamic> _$SignUpFormToJson(SignUpForm instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'schoolName': instance.schoolName,
      'age': instance.age,
      'studentName': instance.studentName,
      'gender': SignUpForm._genderToJson(instance.gender),
    };
