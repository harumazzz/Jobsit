import 'package:dart_either/dart_either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/location_service.dart';
import '../entities/job.dart';

abstract class JobRepository {
  Future<Either<Failure, List<Job>>> getJobs({int page = 1, int limit = 10});

  Future<Either<Failure, Job>> getJobById(int jobId);

  Future<Either<Failure, List<Major>>> getMajors();

  Future<Either<Failure, List<Position>>> getPositions();

  Future<Either<Failure, List<Schedule>>> getSchedules();

  Future<Either<Failure, List<Job>>> getFilteredJobs({
    int page = 1,
    int limit = 10,
    List<Position>? positions,
    List<Schedule>? schedules,
    City? city,
    List<Major>? majors,
    String? title,
  });

  Future<Either<Failure, List<Job>>> getJobsByCompany({int page = 1, int limit = 5, required Company company});

  Future<Either<Failure, List<Job>>> getSavedJobs({int page = 1, int limit = 10});

  Future<Either<Failure, Success>> addSavedJob({required int jobId});

  Future<Either<Failure, Success>> deleteSavedJob({required int jobId});

  Future<Either<Failure, List<Job>>> getAppliedJob({int page = 1, int limit = 10});

  Future<Either<Failure, Job>> applyJob({required int jobId, required String coverLetter, required FileRequest cv});
}
