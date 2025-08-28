import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'common/provider/deep_link_provider.dart';
import 'common/provider/route_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: 'da34c776779354fda0a431b36464bf3a',
    javaScriptAppKey: '92f158e5e841075bc3fb8279291238f7',
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  void delete(FlutterSecureStorage storage) async {
    await storage.deleteAll();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deepLinkProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // final storage = ref.watch(secureStorageProvider);
    //
    // delete(storage);
    //
    
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'KimjungchulMyungjo'
      ),
      // home: const SplashScreen(),
    );
  }
}
