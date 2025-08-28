import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sobienote_flutter/common/provider/secure_storage.dart';
import 'package:sobienote_flutter/images/model/board_image.dart';

import '../common/const/data.dart';
import '../common/provider/dio_provider.dart';
import 'image_repository.dart';

final imagesRepositoryProvider = Provider<ImageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ImageRepository(dio, baseUrl: 'https://$ip/image');
});

final imagesProvider = FutureProvider.autoDispose.family<List<BoardImage>, (int year, int month)>(
      (ref, args) async {
    final repo = ref.watch(imagesRepositoryProvider);
    final memberId = await ref.watch(secureStorageProvider).read(key: MEMBER_ID_KEY);
    final response = await repo.getImages(args.$1, args.$2, int.parse(memberId!));
    return response.data;
  },
);
