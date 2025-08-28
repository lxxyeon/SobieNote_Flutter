import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:sobienote_flutter/common/const/data.dart';
import 'package:sobienote_flutter/images/model/board_image.dart';

import '../common/provider/dio_provider.dart';
import '../common/response/base_response.dart';

part 'image_repository.g.dart';

final imagesRepositoryProvider = Provider<ImageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ImageRepository(dio, baseUrl: 'https://$ip/image');
});

@RestApi()
abstract class ImageRepository {
  factory ImageRepository(Dio dio, {String baseUrl}) = _ImageRepository;

  @GET('/{year}/{month}/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<List<BoardImage>>> getImages(
    @Path('year') int year,
    @Path('month') int month,
    @Path('memberId') int memberId,
  );

  @GET('/{boardId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<BoardImage>> getBoardImage(@Path('boardId') int boardId);
}
