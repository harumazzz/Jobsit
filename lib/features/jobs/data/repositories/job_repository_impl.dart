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

@riverpod
JobRepository jobRepository(Ref ref) {
  final jobRemoteDataSource = ref.watch(jobRemoteDataSourceProvider);
  return JobRepositoryImpl(jobRemoteDataSource);
}

final class JobRepositoryImpl implements JobRepository {
  const JobRepositoryImpl(this._jobRemoteDataSource);

  final JobRemoteDataSource _jobRemoteDataSource;

  @override
  Future<Either<Failure, Job>> getJobById(int id) async {
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

  @override
  Future<Either<Failure, List<Job>>> getJobs({int page = 1, int limit = 10}) async {
    try {
      final result = await _jobRemoteDataSource.getJobs(page: page, limit: limit);
      return Right([...result.contents.map((e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Major>>> getMajors() async {
    try {
      final result = await _jobRemoteDataSource.getMajors();
      return Right([...result.map((e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Position>>> getPositions() async {
    try {
      final result = await _jobRemoteDataSource.getPositions();
      return Right([...result.map((e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getSchedules() async {
    try {
      final result = await _jobRemoteDataSource.getSchedules();
      return Right([...result.map((e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getFilteredJobs({
    int page = 1,
    int limit = 10,
    List<Position>? positions,
    List<Schedule>? schedules,
    City? city,
    List<Major>? majors,
    String? title,
  }) async {
    try {
      final formData = FormData();
      if (positions != null) {
        formData.fields.add(MapEntry('jobPositionIds', positions.map((e) => e.id.toString()).join(',')));
      }
      if (schedules != null) {
        formData.fields.add(MapEntry('jobScheduleIds', schedules.map((e) => e.id.toString()).join(',')));
      }
      if (majors != null) {
        formData.fields.add(MapEntry('jobMajorIds', majors.map((e) => e.id.toString()).join(',')));
      }
      if (city != null) {
        final name = city.name.replaceFirst('Thành phố', '').replaceFirst('Tỉnh', '').trim();
        formData.fields.add(MapEntry('address', name));
      }
      if (title != null) {
        formData.fields.add(MapEntry('title', title));
      }
      formData.fields.add(MapEntry('no', page.toString()));
      formData.fields.add(MapEntry('limit', limit.toString()));
      final result = await _jobRemoteDataSource.getFilteredJobs(formData: formData);
      return Right([...result.contents.map((e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getJobsByCompany({int page = 1, int limit = 5, required Company company}) async {
    try {
      final result = await _jobRemoteDataSource.getJobsByCompany(page: page, limit: limit, companyId: company.id);
      return Right([...result.contents.map((e) => e.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getSavedJobs({int page = 1, int limit = 10}) async {
    try {
      final result = await _jobRemoteDataSource.getSavedJobs(page: page, limit: limit);
      return Right([...result.contents.map((e) => e.job.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> addSavedJob({required int jobId}) async {
    try {
      await _jobRemoteDataSource.addSavedJob(jobId: jobId);
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteSavedJob({required int jobId}) async {
    try {
      await _jobRemoteDataSource.deleteSavedJob(jobId: jobId);
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getAppliedJob({int page = 1, int limit = 10}) async {
    try {
      final result = await _jobRemoteDataSource.getAppliedJob(page: page, limit: limit);
      return Right([...result.contents.map((e) => e.job.toEntity())]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Job>> applyJob({
    required int jobId,
    required String coverLetter,
    required FileRequest cv,
  }) async {
    try {
      final formData = FormData.fromMap({
        'candidateApplication': {'id': jobId, 'coverLetter': coverLetter},
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
