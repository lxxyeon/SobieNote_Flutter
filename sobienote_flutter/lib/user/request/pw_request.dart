import 'package:json_annotation/json_annotation.dart';

part 'pw_request.g.dart';

@JsonSerializable()
class PwRequest {
  final String email;

  PwRequest({required this.email});

  Map<String, dynamic> toJson() => _$PwRequestToJson(this);

  factory PwRequest.fromJson(Map<String, dynamic> json) =>
      _$PwRequestFromJson(json);
}
