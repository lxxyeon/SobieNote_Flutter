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
  final repository = ref.read(userRepositoryProvider);

  final memberIdStr = await storage.read(key: MEMBER_ID_KEY);
  if (memberIdStr == null) {
    throw Exception('memberId not found in secure storage');
  }

  final memberId = int.tryParse(memberIdStr);
  if (memberId == null) {
    throw Exception('Invalid memberId: $memberIdStr');
  }

  final response = await repository.getUserInfo(memberId);
  final userResp = response.data;
  final type = await storage.read(key: SOCIAL_TYPE_KEY);

  return UserModel(
    email: userResp.email,
    type: SocialType.getByName(type!),
    nickName: userResp.name,
    name: userResp.studentName,
    age: userResp.age?.toString(),
    school: userResp.schoolName,
    gender: Gender.fromJson(userResp.gender),
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
    try {
      final memberIdStr = await secureStorage.read(key: MEMBER_ID_KEY);
      if (memberIdStr == null || memberIdStr.isEmpty) {
        state = UserModelError(message: '로그인 정보 없음');
        return;
      }

      final memberId = int.tryParse(memberIdStr);
      if (memberId == null) {
        state = UserModelError(message: '유효하지 않은 회원 ID');
        return;
      }

      final response = await userRepository.getUserInfo(memberId);

      if (response.success) {
        final userResp = response.data;

        final socialTypeName = await secureStorage.read(key: SOCIAL_TYPE_KEY);
        // final genderStr = await secureStorage.read(key: GENDER_KEY);

        await secureStorage.write(key: NAME_KEY, value: userResp.name);
        await secureStorage.write(key: STUDENT_NAME_KEY, value: userResp.studentName);
        await secureStorage.write(key: AGE_KEY, value: userResp.age.toString());
        await secureStorage.write(key: SCHOOL_KEY, value: userResp.schoolName);
        await secureStorage.write(key: EMAIL_KEY, value: userResp.email);
        await secureStorage.write(key: GENDER_KEY, value: Gender.fromJson(userResp.gender)?.name);

        state = UserModel(
          email: userResp.email,
          type: SocialType.getByName(socialTypeName ?? 'LOCAL'),
          nickName: userResp.name,
          name: userResp.studentName,
          age: userResp.age?.toString(),
          school: userResp.schoolName,
          gender: userResp.gender != null
              ? Gender.fromJson(userResp.gender)
              : null,
        );
      } else {
        state = UserModelError(message: '유저 정보 조회 실패');
      }
    } catch (e, st) {
      print('getMe() 오류: $e\n$st');
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
      } else if (loginRequest != null) {
        resp = await authRepository.login(request: loginRequest);
        await secureStorage.write(key: PASSWORD_KEY, value: loginRequest.password);
        await secureStorage.write(key: EMAIL_KEY, value: loginRequest.email);
        await secureStorage.write(key: SOCIAL_TYPE_KEY, value: SocialType.LOCAL.name);
      }

      await secureStorage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);
      await secureStorage.write(
        key: MEMBER_ID_KEY,
        value: resp.memberId.toString(),
      );

      String type = await secureStorage.read(key: SOCIAL_TYPE_KEY) ?? '';
      String email = await secureStorage.read(key: EMAIL_KEY) ?? '';
      String name = await secureStorage.read(key: NAME_KEY) ?? '';
      String school = await secureStorage.read(key: SCHOOL_KEY) ?? '';
      String age = await secureStorage.read(key: AGE_KEY) ?? '';
      String studentName =
          await secureStorage.read(key: STUDENT_NAME_KEY) ?? '';
      String gender = await secureStorage.read(key: GENDER_KEY) ?? '';

      final user = UserModel(
        email: email,
        type: SocialType.getByName(type),
        nickName: name,
        name: studentName,
        age: age,
        school: school,
        gender: gender != '' ? Gender.values.firstWhere((g) => g.name == gender) : null,
      );


      state = user;
      return user;
    } catch (e) {
      state = UserModelError(message: '로그인에 실패했습니다.');
      print('로그인 실패 ${e.toString()}');
      return Future.value(state);
    }
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
    state = null;
  }

  Future<void> deleteAccount() async {
    state = null;
    final memberId = await secureStorage.read(key: MEMBER_ID_KEY);
    await userRepository.deleteAccount(int.parse(memberId!));
    await secureStorage.deleteAll();
  }

  Future<bool> signUp({required SignUpForm form}) async {
    try {
      final resp = await authRepository.signUp(form: form);

      if (resp.success) {
        // 필수 정보 저장
        await secureStorage.write(key: NAME_KEY, value: form.name);
        await secureStorage.write(key: EMAIL_KEY, value: form.email);
        await secureStorage.write(key: PASSWORD_KEY, value: form.password);
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
        await secureStorage.write(key: GENDER_KEY, value: request.gender.name);

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
