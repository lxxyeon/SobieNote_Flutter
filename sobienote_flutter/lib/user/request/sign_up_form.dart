import 'package:json_annotation/json_annotation.dart';

import '../model/user_model.dart';

part 'sign_up_form.g.dart';

@JsonSerializable()
class SignUpForm {
  final String name;
  final String email;
  final String password;
  final String? schoolName;
  final String? age;
  final String? studentName;
  @JsonKey(fromJson: Gender.fromJson, toJson: _genderToJson)
  final Gender? gender;

  SignUpForm({
    required this.name,
    required this.email,
    required this.password,
    this.schoolName,
    this.age,
    this.studentName,
    this.gender,
  });

  static String? _genderToJson(Gender? gender) => gender?.toJson();

  factory SignUpForm.fromJson(Map<String, dynamic> json) =>
      _$SignUpFormFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpFormToJson(this);
}
