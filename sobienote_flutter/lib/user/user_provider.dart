import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sobienote_flutter/user/request/login_request.dart';
import 'package:sobienote_flutter/user/request/sign_up_form.dart';
import 'package:sobienote_flutter/user/request/social_login_request.dart';
import 'package:sobienote_flutter/user/response/oauth_response.dart';
import 'package:sobienote_flutter/user/user_repository.dart';

import '../common/const/data.dart';
import '../common/provider/secure_storage.dart';
import 'auth_repository.dart';
import 'model/user_model.dart';

final userInfoProvider = FutureProvider<UserModel>((ref) async {
  final storage = ref.read(secureStorageProvider);

  final nickname = await storage.read(key: NAME_KEY) ?? '';
  final email = await storage.read(key: EMAIL_KEY) ?? '';
  final name = await storage.read(key: STUDENT_NAME_KEY);
  final age = await storage.read(key: AGE_KEY);
  final school = await storage.read(key: SCHOOL_KEY);
  final type = await storage.read(key: SOCIAL_TYPE_KEY);

  return UserModel(
    nickName: nickname,
    email: email,
    name: name,
    age: age,
    school: school,
    type: SocialType.getByName(type!),
  );
});

final userProvider = StateNotifierProvider<UserStateNotifier, UserModelBase?>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return UserStateNotifier(
    authRepository: authRepository,
    userRepository: userRepository,
    secureStorage: secureStorage,
  );
});

class UserStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final FlutterSecureStorage secureStorage;

  UserStateNotifier({
    required this.authRepository,
    required this.userRepository,
    required this.secureStorage,
  }) : super(UserModelLoading()) {
    getMe();
  }

  Future<void> getMe() async {
    String type = await secureStorage.read(key: SOCIAL_TYPE_KEY) ?? '';
    String email = await secureStorage.read(key: EMAIL_KEY) ?? '';
    String name = await secureStorage.read(key: NAME_KEY) ?? '';
    String memberId = await secureStorage.read(key: MEMBER_ID_KEY) ?? '';
    try {
      if (type.isEmpty || email.isEmpty || name.isEmpty || memberId.isEmpty) {
        state = UserModelError(message: '로그인 정보 없음');
        return;
      }
      await userRepository.socialLogin(
        SocialLoginRequest(
          email: email,
          name: name,
          type: SocialType.getByName(type),
        ),
      );
      state = UserModel(
        email: email,
        type: SocialType.getByName(type),
        nickName: name,
      );
    } catch (e) {
      state = UserModelError(message: '로그인 실패');
    }
  }

  Future<UserModelBase> login({
    SocialLoginRequest? socialLoginRequest,
    LoginRequest? loginRequest,
  }) async {
    try {
      state = UserModelLoading();
      late final resp;
      if (socialLoginRequest != null) {
        resp = await authRepository.socialLogin(request: socialLoginRequest);
      }
      if (loginRequest != null) {
        resp = await authRepository.login(request: loginRequest);
      }
      print('resp in user_provider: $resp');
      await secureStorage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);
      await secureStorage.write(
        key: MEMBER_ID_KEY,
        value: resp.memberId.toString(),
      );
      String type = await secureStorage.read(key: SOCIAL_TYPE_KEY) ?? '';
      String email = await secureStorage.read(key: EMAIL_KEY) ?? '';
      String name = await secureStorage.read(key: NAME_KEY) ?? '';
      print('resp in user_provider: $type, $email, $name');

      final user = UserModel(
        email: email,
        type: SocialType.getByName(type),
        nickName: name,
      );
      state = user;
      return user;
    } catch (e) {
      state = UserModelError(message: '로그인에 실패했습니다.');
      return Future.value(state);
    }
  }

  Future<void> logout() async {
    state = null;
    await Future.wait([secureStorage.deleteAll()]);
  }

  Future<void> deleteAccount() async {
    state = null;
    final memberId = await secureStorage.read(key: MEMBER_ID_KEY);
    await userRepository.deleteAccount(int.parse(memberId!));
    await Future.wait([secureStorage.deleteAll()]);
  }

  Future<bool> signUp({required SignUpForm form}) async {
    try {
      final resp = await authRepository.signUp(form: form);

      if (resp.success) {
        // 필수 정보 저장
        await secureStorage.write(key: NAME_KEY, value: form.name);
        await secureStorage.write(key: EMAIL_KEY, value: form.email);
        await secureStorage.write(
          key: SOCIAL_TYPE_KEY,
          value: SocialType.LOCAL.name,
        );

        if (form.studentName != null) {
          await secureStorage.write(key: STUDENT_NAME_KEY, value: form.studentName);
        }
        if (form.age != null) {
          await secureStorage.write(key: AGE_KEY, value: form.age.toString());
        }
        if (form.schoolName != null) {
          await secureStorage.write(key: SCHOOL_KEY, value: form.schoolName);
        }

        if (resp.data.accessToken != null && resp.data.memberId != null) {
          await secureStorage.write(key: ACCESS_TOKEN_KEY, value: resp.data.accessToken);
          await secureStorage.write(
            key: MEMBER_ID_KEY,
            value: resp.data.memberId.toString(),
          );
          state = UserModel(
            email: form.email,
            nickName: form.name,
            type: SocialType.LOCAL,
            name: form.studentName,
            age: form.age?.toString(),
            school: form.schoolName,
          );
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('회원 가입에 실패했습니다. -> $e');
      return false;
    }
  }

  Future<void> verifyEmailAndLogin(String token) async {
    try {
      final resp = await userRepository.verifyEmail(
        token,
        VerificationType.SIGNUP,
      );

      final oAuthData = resp.data;

      await secureStorage.write(key: ACCESS_TOKEN_KEY, value: oAuthData.accessToken);
      await secureStorage.write(key: MEMBER_ID_KEY, value: oAuthData.memberId.toString());

      final email = await secureStorage.read(key: EMAIL_KEY);
      final name = await secureStorage.read(key: NAME_KEY);
      final type = await secureStorage.read(key: SOCIAL_TYPE_KEY);
      final studentName = await secureStorage.read(key: STUDENT_NAME_KEY);
      final age = await secureStorage.read(key: AGE_KEY);
      final school = await secureStorage.read(key: SCHOOL_KEY);

      state = UserModel(
        email: email!,
        nickName: name!,
        type: SocialType.getByName(type!),
        name: studentName,
        age: age,
        school: school,
      );
    } catch (e) {
      state = UserModelError(message: '이메일 인증 실패: $e');
    }
  }

}
