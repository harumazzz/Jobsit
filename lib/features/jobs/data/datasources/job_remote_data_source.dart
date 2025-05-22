import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/network/dio_client.dart';
import '../models/job_model.dart';

part 'job_remote_data_source.g.dart';

/// Provides an instance of [JobRemoteDataSource].
///
/// This data source is responsible for making API calls related to jobs,
/// including fetching job lists, job details, majors, positions, schedules,
/// and managing saved/applied jobs.
@riverpod
JobRemoteDataSource jobRemoteDataSource(final Ref ref) {
  final dio = ref.watch(dioProvider);
  return _JobRemoteDataSource(dio);
}

/// Abstract class for job-related remote data operations.
///
/// Defines the contract for API calls such as fetching job listings,
/// job details, filtering jobs, managing saved and applied jobs,
/// and retrieving related data like majors, positions, and schedules.
/// Implementations will use a [Dio] client for network requests.
@RestApi()
abstract class JobRemoteDataSource {
  /// Creates a [JobRemoteDataSource] instance.
  ///
  /// Typically, this factory will be used by a code generator (like Retrofit)
  /// to create a concrete implementation.
  factory JobRemoteDataSource(final Dio dio) = _JobRemoteDataSource;

  /// Fetches a paginated list of jobs.
  ///
  /// [page] The page number to fetch (default is 0).
  /// [limit] The number of jobs per page (default is 10).
  @GET(ApiConstant.jobListEndpoint)
  Future<JobListResponse> getJobs({
    @Query('no') final int page = 0,
    @Query('limit') final int limit = 10,
  });

  /// Fetches the details of a specific job by its ID.
  ///
  /// [jobId] The ID of the job to fetch.
  /// Returns [JobResponse] or null if not found.
  @GET(ApiConstant.jobDetailEndpoint)
  Future<JobResponse?> getJobById(@Path() final int jobId);

  /// Fetches a list of all available majors.
  @GET(ApiConstant.majorListEndpoint)
  Future<List<MajorResponse>> getMajors();

  /// Fetches a list of all available job positions.
  @GET(ApiConstant.positionListEndpoint)
  Future<List<PositionResponse>> getPositions();

  /// Fetches a list of all available work schedules/types.
  @GET(ApiConstant.scheduleListEndpoint)
  Future<List<ScheduleResponse>> getSchedules();

  /// Fetches a list of jobs based on filter criteria.
  ///
  /// [formData] Contains the filter parameters for the job search.
  @GET(ApiConstant.jobFilterEndpoint)
  Future<JobListResponse> getFilteredJobs({
    @Body() required final FormData formData,
  });

  /// Fetches a paginated list of jobs for a specific company.
  ///
  /// [companyId] The ID of the company.
  /// [page] The page number to fetch (default is 0).
  /// [limit] The number of jobs per page (default is 5).
  @GET(ApiConstant.jobListByCompanyEndpoint)
  Future<JobListResponse> getJobsByCompany({
    @Path('companyId') required final int companyId,
    @Query('no') final int page = 0,
    @Query('limit') final int limit = 5,
  });

  /// Fetches a paginated list of jobs saved by the current user.
  ///
  /// [page] The page number to fetch (default is 0).
  /// [limit] The number of jobs per page (default is 10).
  @GET(ApiConstant.jobSaveEndpoint)
  Future<SavedJobListResponse> getSavedJobs({
    @Query('no') final int page = 0,
    @Query('limit') final int limit = 10,
  });

  /// Adds a job to the current user's saved jobs list.
  ///
  /// [jobId] The ID of the job to save.
  @POST(ApiConstant.jobSaveEndpoint)
  Future<HttpResponse> addSavedJob({
    @Query('idJob') required final int jobId,
  });

  /// Deletes a job from the current user's saved jobs list.
  ///
  /// [jobId] The ID of the job to remove from saved list.
  @DELETE(ApiConstant.jobSaveEndpoint)
  Future<HttpResponse> deleteSavedJob({
    @Query('idJob') required final int jobId,
  });

  /// Fetches a paginated list of jobs applied for by the current user.
  ///
  /// [page] The page number to fetch (default is 0).
  /// [limit] The number of jobs per page (default is 10).
  @GET(ApiConstant.jobAppliedEndpoint)
  Future<SavedJobListResponse> getAppliedJob({
    @Query('no') final int page = 0,
    @Query('limit') final int limit = 10,
  });

  /// Submits a job application.
  ///
  /// [formData] Contains the application details, potentially including
  /// a CV file and cover letter.
  @POST(ApiConstant.jobAppliedEndpoint)
  Future<AppliedJobResponse> applyJob({
    @Body() required final FormData formData,
  });
}
