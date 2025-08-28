import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sobienote_flutter/common/const/colors.dart';
import 'package:sobienote_flutter/user/request/pw_request.dart';

import '../user/request/pw_reset_form.dart';
import '../user/user_provider.dart';

class FindUserBottomSheet extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  final String? memberId;

  const FindUserBottomSheet({
    super.key,
    required this.parentContext,
    this.memberId,
  });

  @override
  ConsumerState<FindUserBottomSheet> createState() =>
      _FindUserBottomSheetState();
}

class _FindUserBottomSheetState extends ConsumerState<FindUserBottomSheet> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildEmailInputUI() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이메일을 입력해주세요.', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text('비밀번호 재설정을 위한 인증 메일이 전송됩니다.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: GRAY_06),
              ),
              hintText: 'abc@naver.com',
              hintStyle: TextStyle(color: GRAY_06),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DARK_TEAL,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                // 이메일 인증 요청 API 호출
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('이메일을 입력해주세요.')));
                  return;
                }
                final resp = await ref
                    .read(userProvider.notifier)
                    .passwordRequest(request: PwRequest(email: email));
                if (resp) {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text('비밀번호 재설정\n링크 메일 전송 완료'),
                        content: Text('메일을 확인하여 비밀번호를 재설정해주세요.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('확인'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('이메일 인증하기', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetUI() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('새로운 비밀번호를 입력해주세요.', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            '영어, 숫자, 특수문자를 포함하여 8~13자리까지 입력해주세요.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: GRAY_06),
              ),
              hintText: '비밀번호',
              hintStyle: TextStyle(color: GRAY_06),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: GRAY_06),
              ),
              hintText: '비밀번호 확인',
              hintStyle: TextStyle(color: GRAY_06),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DARK_TEAL,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                final password = passwordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
                  return;
                }

                final _isValid =
                    RegExp(
                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*()_+~])[A-Za-z\d!@#\$%^&*()_+~]{8,20}$',
                    ).hasMatch(password) &&
                    password == confirmPassword;
                // 비밀번호 재설정 API 호출
                if (_isValid) {
                  final resp = await ref
                      .read(userProvider.notifier)
                      .passwordReset(
                        request: PwResetForm(
                          memberId: widget.memberId!,
                          password: password,
                        ),
                      );
                  if (resp) {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text('비밀번호 재설정 완료'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('확인'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: Text('비밀번호 재설정하기', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.9,
      width: double.infinity,
      child: Padding(
        padding: MediaQuery.of(
          context,
        ).viewInsets.add(const EdgeInsets.all(24)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/find_user.jpeg',
                height: height * 0.15,
              ),
              const SizedBox(height: 12),
              Text(
                '비밀번호 재설정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DARK_TEAL,
                ),
              ),
              Divider(thickness: 2, color: DARK_TEAL),
              const SizedBox(height: 12),
              widget.memberId == null
                  ? _buildEmailInputUI()
                  : _buildPasswordResetUI(),
            ],
          ),
        ),
      ),
    );
  }
}
