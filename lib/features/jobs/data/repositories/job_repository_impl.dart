import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
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

class JobRepositoryImpl implements JobRepository {
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
}
