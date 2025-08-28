import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:sobienote_flutter/common/const/data.dart';
import 'package:sobienote_flutter/common/response/base_response.dart';
import 'package:sobienote_flutter/user/request/login_request.dart';
import 'package:sobienote_flutter/user/request/pw_request.dart';
import 'package:sobienote_flutter/user/request/pw_reset_form.dart';
import 'package:sobienote_flutter/user/request/sign_up_form.dart';
import 'package:sobienote_flutter/user/request/social_login_request.dart';
import 'package:sobienote_flutter/user/request/student_update_form.dart';
import 'package:sobienote_flutter/user/response/oauth_response.dart';
import 'package:sobienote_flutter/user/response/user_response.dart';

import '../common/provider/dio_provider.dart';

part 'user_repository.g.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRepository(dio, baseUrl: 'https://$ip/member');
});

@RestApi()
abstract class UserRepository {
  factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;

  @GET('/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<UserResponse>> getUserInfo(
    @Path('memberId') int memberId,
  );

  @POST('/social')
  Future<BaseResponse<OAuthResponse>> socialLogin(
    @Body() SocialLoginRequest request,
  );

  @POST('/signup')
  Future<BaseResponse<OAuthResponse>> signUp(@Body() SignUpForm request);

  @POST('/password/request')
  Future<BaseResponse<String>> passwordRequest(@Body() PwRequest request);

  @POST('/password/reset')
  Future<BaseResponse<String>> passwordReset(@Body() PwResetForm request);

  @POST('/login')
  Future<BaseResponse<OAuthResponse>> login(@Body() LoginRequest request);

  @PATCH('/student/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<int>> updateStudent(
    @Body() StudentUpdateForm form,
    @Path('memberId') int memberId,
  );

  @DELETE('/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<int>> deleteAccount(@Path('memberId') int memberId);
}
