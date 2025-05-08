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

  @GET(ApiConstant.majorListEndpoint)
  Future<List<MajorResponse>> getMajors();

  @GET(ApiConstant.positionListEndpoint)
  Future<List<PositionResponse>> getPositions();

  @GET(ApiConstant.scheduleListEndpoint)
  Future<List<ScheduleResponse>> getSchedules();

  @GET(ApiConstant.jobFilterEndpoint)
  Future<JobListResponse> getFilteredJobs({@Body() required FormData formData});

  @GET(ApiConstant.jobListByCompanyEndpoint)
  Future<JobListResponse> getJobsByCompany({
    @Path('companyId') required int companyId,
    @Query('no') int page = 0,
    @Query('limit') int limit = 5,
  });

  @GET(ApiConstant.jobSaveEndpoint)
  Future<SavedJobListResponse> getSavedJobs({@Query('no') int page = 0, @Query('limit') int limit = 10});

  @POST(ApiConstant.jobSaveEndpoint)
  Future<HttpResponse> addSavedJob({@Query('idJob') required int jobId});

  @DELETE(ApiConstant.jobSaveEndpoint)
  Future<HttpResponse> deleteSavedJob({@Query('idJob') required int jobId});

  @GET(ApiConstant.jobAppliedEndpoint)
  Future<SavedJobListResponse> getAppliedJob({@Query('no') int page = 0, @Query('limit') int limit = 10});

  @POST(ApiConstant.jobAppliedEndpoint)
  Future<AppliedJobResponse> applyJob({@Body() required FormData formData});
}
