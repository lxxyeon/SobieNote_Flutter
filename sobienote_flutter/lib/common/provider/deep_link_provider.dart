import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sobienote_flutter/common/const/data.dart';
import 'package:sobienote_flutter/common/provider/route_provider.dart';
import 'package:sobienote_flutter/common/provider/secure_storage.dart';

import '../../component/find_user_bottom_sheet.dart';
import '../../user/user_provider.dart';

final deepLinkProvider = StateNotifierProvider<DeepLinkNotifier, Uri?>((ref) {
  return DeepLinkNotifier(ref);
});

class DeepLinkNotifier extends StateNotifier<Uri?> {
  final Ref ref;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  DeepLinkNotifier(this.ref) : super(null) {
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleUri(initialLink);
      }
      _sub = _appLinks.uriLinkStream.listen((Uri uri) {
        _handleUri(uri);
      });
    } catch (e) {
      print('딥링크 처리 에러: $e');
    }
  }

  void _handleUri(Uri uri) async {
    state = uri;

    final val = uri.queryParameters['val'];
    final memberId = uri.queryParameters['memberId'];

    if (val == 'SIGNUP') {
      final accessToken = uri.queryParameters['accessToken'];
      if (accessToken != null && memberId != null) {
        await ref.read(secureStorageProvider).write(key: MEMBER_ID_KEY, value: memberId);
        await ref.read(secureStorageProvider).write(key: ACCESS_TOKEN_KEY, value: accessToken);
        await ref.read(userProvider.notifier)
            .getMe();
        final context = navigatorKey.currentContext;
        if (context != null) {
          await showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('인증 완료'),
              content: const Text('이메일 인증이 완료되었습니다.\n메인 화면으로 이동합니다.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(routerProvider).go('/');
                  },
                ),
              ],
            ),
          );
        }
      }
    } else if (val == 'RESET') {
      ref.read(routerProvider).go('/login');

      Future.delayed(const Duration(milliseconds: 300), () {
        final context = navigatorKey.currentContext;
        if (context != null) {
          showModalBottomSheet(
            backgroundColor: Colors.white,
            isScrollControlled: true,
            context: context,
            builder: (_) => FindUserBottomSheet(
              parentContext: context,
              memberId: memberId,
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
