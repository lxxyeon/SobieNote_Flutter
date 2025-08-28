import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:sobienote_flutter/common/response/base_response.dart';
import 'package:sobienote_flutter/report/response/report_response.dart';

import '../common/const/data.dart';
import '../common/provider/dio_provider.dart';

part 'report_repository.g.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportRepository(dio, baseUrl: 'https://$ip/report');
});

@RestApi()
abstract class ReportRepository {
  factory ReportRepository(Dio dio, {String baseUrl}) = _ReportRepository;

  @GET('/satisfactions/{year}/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<ReportResponse>> getSatisfaction(
    @Path('year') int year,
    @Path('memberId') int memberId,
    @Query('month') int? month,
  );

  @GET('/satisfactions/avg/{year}/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<double>> getAvgSatisfaction(
    @Path('year') int year,
    @Path('memberId') int memberId,
    @Query('month') int? month,
  );

  @GET('/factors/{year}/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<List<ReportResponse>>> getFactors(
    @Path('year') int year,
    @Path('memberId') int memberId,
    @Query('month') int? month,
  );

  @GET('/emotions/{year}/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<List<ReportResponse>>> getEmotions(
    @Path('year') int year,
    @Path('memberId') int memberId,
    @Query('month') int? month,
  );

  @GET('/categories/{year}/{memberId}')
  @Headers({'accessToken': 'true'})
  Future<BaseResponse<List<ReportResponse>>> getCategories(
    @Path('year') int year,
    @Path('memberId') int memberId,
    @Query('month') int? month,
  );
}
