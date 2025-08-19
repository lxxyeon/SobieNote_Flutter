import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sobienote_flutter/common/const/colors.dart';
import 'package:sobienote_flutter/component/sign_up_bottom_sheet.dart';
import 'package:sobienote_flutter/user/request/social_login_request.dart';

import '../user/request/login_request.dart';
import '../user/user_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  static String get routeName => 'onboarding';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    final size = MediaQuery.of(context).size;
    final aspectRatio = 9 / 20;

    double targetWidth = size.width;
    double targetHeight = size.width / aspectRatio;

    if (targetHeight > size.height) {
      targetHeight = size.height;
      targetWidth = size.height * aspectRatio;
    }

    final horizontalPadding = (size.width - targetWidth) / 2;
    final verticalPadding = (size.height - targetHeight) / 2;

    return Scaffold(
      backgroundColor: DARK_TEAL,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: targetWidth,
            height: targetHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/new_splash.png',
                  fit: BoxFit.cover,
                  width: 300,
                ),
                Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: '이메일',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '비밀번호',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 60),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(userProvider.notifier)
                                .login(
                                  loginRequest: LoginRequest(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(userProvider.notifier)
                                .login(
                                  socialLoginRequest: SocialLoginRequest(
                                    email: '',
                                    name: '',
                                    type: SocialType.KAKAO,
                                  ),
                                );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: KAKAO_YELLOW,
                              width: 40,
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset(
                                  'assets/images/logo_kakao.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(userProvider.notifier)
                                .login(
                                  socialLoginRequest: SocialLoginRequest(
                                    email: '',
                                    name: '',
                                    type: SocialType.GOOGLE,
                                  ),
                                );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: Colors.white,
                              width: 40,
                              height: 40,
                              child: Image.asset(
                                'assets/images/logo_google.png',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder:
                                  (_) =>
                                      SignUpBottomSheet(parentContext: context),
                            );
                          },
                          child: const Text(
                            '가입 하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: GRAY_00,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Container(color: GRAY_00, height: 16, width: 2),
                        // const SizedBox(width: 6),
                        // TextButton(
                        //   onPressed: () {},
                        //   child: const Text(
                        //     '회원 찾기',
                        //     style: TextStyle(
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.w700,
                        //       color: GRAY_00,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
