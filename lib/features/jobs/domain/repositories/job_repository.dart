import 'package:dart_either/dart_either.dart';

import '../../../../core/error/failures.dart';
import '../entities/job.dart';

abstract class JobRepository {
  Future<Either<Failure, List<Job>>> getJobs({int page = 1, int limit = 10});

  Future<Either<Failure, Job>> getJobById(int jobId);

  Future<Either<Failure, List<Major>>> getMajors();

  Future<Either<Failure, List<Position>>> getPositions();

  Future<Either<Failure, List<Schedule>>> getSchedules();
}
