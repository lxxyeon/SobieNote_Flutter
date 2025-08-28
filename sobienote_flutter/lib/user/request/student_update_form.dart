import 'package:json_annotation/json_annotation.dart';
import 'package:sobienote_flutter/user/model/user_model.dart';

part 'student_update_form.g.dart';

@JsonSerializable()
class StudentUpdateForm {
  final String schoolName;
  final String age;
  final String studentName;
  final Gender gender;

  StudentUpdateForm({
    required this.schoolName,
    required this.age,
    required this.studentName,
    required this.gender,
  });

  factory StudentUpdateForm.fromJson(Map<String, dynamic> json) => _$StudentUpdateFormFromJson(json);
  Map<String, dynamic> toJson() => _$StudentUpdateFormToJson(this);

}
