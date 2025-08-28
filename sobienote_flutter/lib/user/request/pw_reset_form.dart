import 'package:json_annotation/json_annotation.dart';

part 'pw_reset_form.g.dart';

@JsonSerializable()
class  PwResetForm{
  final String memberId;
  final String password;

  PwResetForm({required this.memberId, required this.password});

  Map<String, dynamic> toJson() => _$PwResetFormToJson(this);
}