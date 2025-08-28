import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:sobienote_flutter/common/provider/dio_provider.dart';
import 'package:sobienote_flutter/common/response/base_response.dart';
import 'package:sobienote_flutter/goal/request/goal_request.dart';
import 'package:sobienote_flutter/goal/response/goal_response.dart';

import '../common/const/data.dart';

part 'goal_repository.g.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return GoalRepository(dio, baseUrl: 'https://$ip/goal');
});

@RestApi()
abstract class GoalRepository {
  factory GoalRepository(Dio dio, {String baseUrl}) = _GoalRepository;

  @GET('/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<String>> getGoal(@Path('memberId') int memberId, @Query('year') int year, @Query('month') int month);

  @POST('/{memberId}')
  @Headers({'accessToken': 'true', 'Content-Type': 'application/json'})
  Future<BaseResponse<GoalResponse>> setGoal(
    @Path('memberId') int memberId,
    @Query('year') int year,
    @Query('month') int month,
    @Body() GoalRequest body,
  );
}
