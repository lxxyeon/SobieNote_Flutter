import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sobienote_flutter/user/request/login_request.dart';
import 'package:sobienote_flutter/user/request/pw_request.dart';
import 'package:sobienote_flutter/user/request/pw_reset_form.dart';
import 'package:sobienote_flutter/user/request/sign_up_form.dart';
import 'package:sobienote_flutter/user/request/social_login_request.dart';
import 'package:sobienote_flutter/user/request/student_update_form.dart';
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
  final genderStr = await storage.read(key: GENDER_KEY);

  final gender = genderStr != null
      ? Gender.values.firstWhere(
        (g) => g.name == genderStr,
    orElse: () => Gender.FEMALE,
  )
      : Gender.FEMALE;

  return UserModel(
    nickName: nickname,
    email: email,
    name: name,
    age: age,
    school: school,
    type: SocialType.getByName(type!),
    gender: gender,
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
        print('$state 로그인 정보 없음');
        return;
      }
      final resp = await userRepository.socialLogin(
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
      print('$state 로그인 실패');
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
          await secureStorage.write(
            key: STUDENT_NAME_KEY,
            value: form.studentName,
          );
        }
        if (form.age != null) {
          await secureStorage.write(key: AGE_KEY, value: form.age.toString());
        }
        if (form.schoolName != null) {
          await secureStorage.write(key: SCHOOL_KEY, value: form.schoolName);
        }

        if (resp.data.accessToken != null && resp.data.memberId != null) {
          await secureStorage.write(
            key: ACCESS_TOKEN_KEY,
            value: resp.data.accessToken,
          );
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

  Future<bool> passwordRequest({required PwRequest request}) async {
    try {
      final resp = await userRepository.passwordRequest(request);
      if (resp.success) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('비밀번호 찾기 요청에 실패했습니다. -> $e');
      return false;
    }
  }

  Future<bool> passwordReset({required PwResetForm request}) async {
    try {
      final resp = await userRepository.passwordReset(request);
      if (resp.success) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('비밀번호 찾기 요청에 실패했습니다. -> $e');
      return false;
    }
  }

  Future<bool> updateStudent({required StudentUpdateForm request}) async {
    try {
      final memberId = await secureStorage.read(key: MEMBER_ID_KEY);
      if (memberId == null) {
        return false;
      }
      final resp = await userRepository.updateStudent(
        request,
        int.parse(memberId),
      );

      if (resp.success) {
        await secureStorage.write(
          key: STUDENT_NAME_KEY,
          value: request.studentName,
        );
        await secureStorage.write(key: AGE_KEY, value: request.age.toString());
        await secureStorage.write(key: SCHOOL_KEY, value: request.schoolName);
        await secureStorage.write(
          key: GENDER_KEY,
          value: request.gender.name,
        );

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('학생 정보 수정에 실패했습니다. -> $e');
      return false;
    }
  }
}
