import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sobienote_flutter/common/const/colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // final AppLinks _appLinks = AppLinks();
  //
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _handleInitialLink();
  //   });
  // }

  // Future<void> _handleInitialLink() async {
  //   try {
  //     final uri = await _appLinks.getInitialLink();
  //     if (uri != null && uri.path == '/verify') {
  //       final token = uri.queryParameters['token'];
  //       if (token != null && token.isNotEmpty) {
  //         await ref.read(userProvider.notifier).verifyEmailAndLogin(token);
  //         if (mounted) {
  //           context.go('/'); // 인증 완료 후 홈으로 이동
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('딥링크 처리 중 오류 발생: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DARK_TEAL,
      body: Container(
          margin: const EdgeInsets.only(top: 80),
          child: Image.asset('assets/images/new_onboarding.jpeg')),
    );
  }
}
