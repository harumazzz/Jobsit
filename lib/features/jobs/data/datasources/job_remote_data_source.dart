import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/network/dio_client.dart';
import '../models/job_model.dart';

part 'job_remote_data_source.g.dart';

@riverpod
JobRemoteDataSource jobRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return _JobRemoteDataSource(dio);
}

@RestApi()
abstract class JobRemoteDataSource {
  factory JobRemoteDataSource(Dio dio) = _JobRemoteDataSource;

  @GET(ApiConstant.jobListEndpoint)
  Future<JobListResponse> getJobs({@Query('no') int page = 0, @Query('limit') int limit = 10});

  @GET(ApiConstant.jobDetailEndpoint)
  Future<JobResponse?> getJobById(@Path() int jobId);
}
