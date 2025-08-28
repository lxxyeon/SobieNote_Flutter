// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_update_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentUpdateForm _$StudentUpdateFormFromJson(Map<String, dynamic> json) =>
    StudentUpdateForm(
      schoolName: json['schoolName'] as String,
      age: json['age'] as String,
      studentName: json['studentName'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
    );

Map<String, dynamic> _$StudentUpdateFormToJson(StudentUpdateForm instance) =>
    <String, dynamic>{
      'schoolName': instance.schoolName,
      'age': instance.age,
      'studentName': instance.studentName,
      'gender': instance.gender,
    };

const _$GenderEnumMap = {Gender.FEMALE: 'FEMALE', Gender.MALE: 'MALE'};
