import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sobienote_flutter/common/provider/secure_storage.dart';
import 'package:sobienote_flutter/common/response/base_response.dart';
import 'package:sobienote_flutter/user/request/login_request.dart';
import 'package:sobienote_flutter/user/request/sign_up_form.dart';
import 'package:sobienote_flutter/user/request/social_login_request.dart';
import 'package:sobienote_flutter/user/response/oauth_response.dart';
import 'package:sobienote_flutter/user/user_repository.dart';

import '../common/const/data.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthRepository(storage: storage, userRepository: userRepository);
});

class AuthRepository {
  final FlutterSecureStorage storage;
  final UserRepository userRepository;

  AuthRepository({required this.storage, required this.userRepository});

  Future<OAuthResponse> socialLogin({required SocialLoginRequest request}) async {
    if (request.type == SocialType.KAKAO) {
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');

          if (error is PlatformException && error.code == 'CANCELED') {
            return Future.value(null);
          }

          try {
            await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공');
          } catch (error) {
            print('카카오계정으로 로그인 실패 $error');
          }
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
      User user = await UserApi.instance.me();
      print('kakao user info : ${user.kakaoAccount.toString()}');
      request = SocialLoginRequest(
        name: user.kakaoAccount!.profile!.nickname!,
        email: user.kakaoAccount!.email!,
        type: request.type,
      );
    }

    if (request.type == SocialType.GOOGLE) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google 로그인 실패 또는 취소됨');
      }

      request = SocialLoginRequest(
        name: account.displayName ?? '',
        email: account.email,
        type: SocialType.GOOGLE,
      );
    }

    final resp = await userRepository.socialLogin(request);

    print('resp = ${resp.data.toString()}');

    await storage.write(key: NAME_KEY, value: request.name);
    await storage.write(key: EMAIL_KEY, value: request.email);
    await storage.write(key: SOCIAL_TYPE_KEY, value: request.type.name);

    return resp.data;
  }

  Future<OAuthResponse> login({required LoginRequest request}) async {
    final resp = await userRepository.login(request);
    print('resp = ${resp.data.toString()}');

    await storage.write(key: NAME_KEY, value: request.password);
    await storage.write(key: EMAIL_KEY, value: request.email);
    await storage.write(key: SOCIAL_TYPE_KEY, value: SocialType.LOCAL.name);

    return resp.data;
  }
  
  Future<BaseResponse<OAuthResponse>> signUp({required SignUpForm form}) async {
    final resp = await userRepository.signUp(form);
    return resp;
  }
}
