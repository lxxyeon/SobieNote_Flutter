import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sobienote_flutter/common/provider/secure_storage.dart';
import 'package:sobienote_flutter/user/model/user_model.dart';
import 'package:sobienote_flutter/user/request/login_request.dart';

import '../../user/request/social_login_request.dart';
import '../../user/user_provider.dart';
import '../const/data.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);
  dio.interceptors.add(CustomInterceptor(storage: storage, ref: ref));
  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({required this.storage, required this.ref});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print(
      '[ERR] [${err.requestOptions.method}] [${err.requestOptions.uri}] [${err.response?.statusCode}]',
    );

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    if (accessToken == null) {
      handler.reject(err);
    }

    if (err.response?.statusCode == 404) {
    } else if (err.response?.statusCode == 403) {
      final email = await storage.read(key: EMAIL_KEY);
      final name = await storage.read(key: NAME_KEY);
      final type = await storage.read(key: SOCIAL_TYPE_KEY);

      if (email == null || name == null || type == null) {
        handler.reject(err);
        return;
      }
      late final resp;
      if (SocialType.getByName(type) == SocialType.LOCAL) {
        resp = await ref
            .read(userProvider.notifier)
            .login(loginRequest: LoginRequest(email: email, password: name));
      } else {
        resp = await ref
            .read(userProvider.notifier)
            .login(
              socialLoginRequest: SocialLoginRequest(
                email: email,
                name: name,
                type: SocialType.getByName(type!),
              ),
            );
      }

      if (resp is UserModel) {
        final options = err.requestOptions;
        final dio = Dio();
        String accessToken = await storage.read(key: ACCESS_TOKEN_KEY) ?? '';
        options.headers.addAll({'authorization': 'Bearer $accessToken'});
        final response = await dio.fetch(options);
        handler.resolve(response);
      } else if (resp is UserModelError) {
        return;
      }
      return;
    } else {
      final data = err.response?.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        final error = data['error'];
        // final code = error['code'];
        // final message = error['message'];
        // print('MESSAGE: $message');
      } else {
        print('Unknown error format: ${err.response?.data}');
      }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '[RES] [${response.requestOptions.method}] [${response.requestOptions.uri}]',
    );

    return super.onResponse(response, handler);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('[REQ] [${options.method}] [${options.uri}]');

    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    return super.onRequest(options, handler);
  }
}
