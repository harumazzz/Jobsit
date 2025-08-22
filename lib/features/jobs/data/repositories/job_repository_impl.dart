import 'dart:convert';

import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_data_source.dart';
import '../models/job_model.dart';

part 'job_repository_impl.g.dart';

/// Provides an instance of [JobRepository].
///
/// This repository handles job-related data operations, interacting with
/// [JobRemoteDataSource].
@riverpod
JobRepository jobRepository(final Ref ref) {
  final jobRemoteDataSource = ref.watch(jobRemoteDataSourceProvider);
  return JobRepositoryImpl(jobRemoteDataSource);
}

/// Implementation of the [JobRepository] interface.
///
/// This class interacts with [JobRemoteDataSource] for network operations
/// related to jobs.
final class JobRepositoryImpl implements JobRepository {
  /// Creates a [JobRepositoryImpl].
  ///
  /// Requires a [JobRemoteDataSource].
  const JobRepositoryImpl(this._jobRemoteDataSource);

  final JobRemoteDataSource _jobRemoteDataSource;

  /// Fetches a job by its ID.
  ///
  /// Returns a [Job] entity wrapped in an [Either] type. If the job is not
  /// found, a [ServerFailure] is returned.
  @override
  Future<Either<Failure, Job>> getJobById(final int id) async {
    try {
      final result = await _jobRemoteDataSource.getJobById(id);
      if (result == null) {
        return const Left(ServerFailure('Job not found'));
      }
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches a paginated list of jobs.
  ///
  /// Returns a list of [Job] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Job>>> getJobs({
    final int page = 1,
    final int limit = 10,
  }) async {
    try {
      final result = await _jobRemoteDataSource.getJobs(
        page: page,
        limit: limit,
      );
      return Right([...result.contents.map((final e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches a list of majors.
  ///
  /// Returns a list of [Major] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Major>>> getMajors() async {
    try {
      final result = await _jobRemoteDataSource.getMajors();
      return Right([...result.map((final e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches a list of positions.
  ///
  /// Returns a list of [Position] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Position>>> getPositions() async {
    try {
      final result = await _jobRemoteDataSource.getPositions();
      return Right([...result.map((final e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches a list of schedules.
  ///
  /// Returns a list of [Schedule] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Schedule>>> getSchedules() async {
    try {
      final result = await _jobRemoteDataSource.getSchedules();
      return Right([...result.map((final e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches a filtered list of jobs based on criteria.
  ///
  /// Returns a list of [Job] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Job>>> getFilteredJobs({
    final int page = 1,
    final int limit = 10,
    final List<Position>? positions,
    final List<Schedule>? schedules,
    final City? city,
    final List<Major>? majors,
    final String? title,
  }) async {
    try {
      final formData = FormData();
      if (positions != null) {
        final value = positions.map((final e) => e.id.toString());
        formData.fields.add(MapEntry('jobPositionIds', value.join(',')));
      }
      if (schedules != null) {
        final value = schedules.map((final e) => e.id.toString());
        formData.fields.add(MapEntry('jobScheduleIds', value.join(',')));
      }
      if (majors != null) {
        final value = majors.map((final e) => e.id.toString());
        formData.fields.add(MapEntry('jobMajorIds', value.join(',')));
      }
      if (city != null) {
        // ignore: lines_longer_than_80_chars
        final name = city.name.replaceFirst('Thành phố', '').replaceFirst('Tỉnh', '').trim();
        formData.fields.add(MapEntry('address', name));
      }
      if (title != null) {
        formData.fields.add(MapEntry('title', title));
      }
      formData.fields.add(MapEntry('no', page.toString()));
      formData.fields.add(MapEntry('limit', limit.toString()));
      final result = await _jobRemoteDataSource.getFilteredJobs(
        formData: formData,
      );
      return Right([...result.contents.map((final e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches jobs by a specific company.
  ///
  /// Returns a list of [Job] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Job>>> getJobsByCompany({
    final int page = 1,
    final int limit = 5,
    required final Company company,
  }) async {
    try {
      final result = await _jobRemoteDataSource.getJobsByCompany(
        page: page,
        limit: limit,
        companyId: company.id,
      );
      return Right([...result.contents.map((final e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches saved jobs for the user.
  ///
  /// Returns a list of [Job] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Job>>> getSavedJobs({
    final int page = 1,
    final int limit = 10,
  }) async {
    try {
      final result = await _jobRemoteDataSource.getSavedJobs(
        page: page,
        limit: limit,
      );
      return Right([...result.contents.map((final e) => e.job.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Adds a job to the user's saved jobs.
  ///
  /// Returns a [Success] entity wrapped in an [Either] type.
  @override
  Future<Either<Failure, Success>> addSavedJob({
    required final int jobId,
  }) async {
    try {
      await _jobRemoteDataSource.addSavedJob(jobId: jobId);
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Deletes a job from the user's saved jobs.
  ///
  /// Returns a [Success] entity wrapped in an [Either] type.
  @override
  Future<Either<Failure, Success>> deleteSavedJob({
    required final int jobId,
  }) async {
    try {
      await _jobRemoteDataSource.deleteSavedJob(jobId: jobId);
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetches jobs applied by the user.
  ///
  /// Returns a list of [Job] entities wrapped in an [Either] type.
  @override
  Future<Either<Failure, List<Job>>> getAppliedJob({
    final int page = 1,
    final int limit = 10,
  }) async {
    try {
      final result = await _jobRemoteDataSource.getAppliedJob(
        page: page,
        limit: limit,
      );
      return Right([...result.contents.map((final e) => e.job.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Applies for a job.
  ///
  /// Requires the job ID, a cover letter, and a CV file. Returns the applied
  /// [Job] entity wrapped in an [Either] type.
  @override
  Future<Either<Failure, Job>> applyJob({
    required final int jobId,
    required final String coverLetter,
    required final FileRequest cv,
  }) async {
    try {
      final formData = FormData.fromMap({
        'candidateApplication': jsonEncode({
          'jobDTO': {'id': jobId},
          'referenceLetter': coverLetter,
        }),
        'fileCV': MultipartFile.fromBytes(cv.data, filename: cv.name),
      });
      final result = await _jobRemoteDataSource.applyJob(formData: formData);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
