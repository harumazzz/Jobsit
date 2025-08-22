import 'package:dart_either/dart_either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/location_service.dart';
import '../entities/job.dart';

/// Abstract repository defining the contract for job-related operations.
///
/// This includes fetching job listings, details, filtering jobs,
/// managing saved and applied jobs, and retrieving related data like
/// majors, positions, and schedules.
abstract class JobRepository {
  /// Fetches a paginated list of jobs.
  ///
  /// [page] The page number to retrieve (defaults to 1).
  /// [limit] The number of jobs per page (defaults to 10).
  /// Returns a list of [Job] entities on success, or a [Failure] on error.
  Future<Either<Failure, List<Job>>> getJobs({
    final int page = 1,
    final int limit = 10,
  });

  /// Fetches the details of a specific job by its ID.
  ///
  /// [jobId] The ID of the job to retrieve.
  /// Returns a [Job] entity on success, or a [Failure] on error.
  Future<Either<Failure, Job>> getJobById(final int jobId);

  /// Fetches a list of all available academic majors.
  ///
  /// Returns a list of [Major] entities on success, or a [Failure] on error.
  Future<Either<Failure, List<Major>>> getMajors();

  /// Fetches a list of all available job positions.
  ///
  /// Returns a list of [Position] entities on success, or a [Failure] on error.
  Future<Either<Failure, List<Position>>> getPositions();

  /// Fetches a list of all available work schedules/types.
  ///
  /// Returns a list of [Schedule] entities on success, or a [Failure] on error.
  Future<Either<Failure, List<Schedule>>> getSchedules();

  /// Fetches a list of jobs based on specified filter criteria.
  ///
  /// [page] The page number for pagination (defaults to 1).
  /// [limit] The number of items per page (defaults to 10).
  /// [positions] Optional list of [Position]s to filter by.
  /// [schedules] Optional list of [Schedule]s to filter by.
  /// [city] Optional [City] to filter by location.
  /// [majors] Optional list of [Major]s to filter by.
  /// [title] Optional job title keyword to search for.
  /// Returns a list of [Job] entities matching the filters on success,
  /// or a [Failure] on error.
  Future<Either<Failure, List<Job>>> getFilteredJobs({
    final int page = 1,
    final int limit = 10,
    final List<Position>? positions,
    final List<Schedule>? schedules,
    final City? city,
    final List<Major>? majors,
    final String? title,
  });

  /// Fetches a paginated list of jobs offered by a specific company.
  ///
  /// [page] The page number (defaults to 1).
  /// [limit] The number of jobs per page (defaults to 5).
  /// [company] The [Company] entity for which to fetch jobs.
  /// Returns a list of [Job] entities on success, or a [Failure] on error.
  Future<Either<Failure, List<Job>>> getJobsByCompany({
    final int page = 1,
    final int limit = 5,
    required final Company company,
  });

  /// Fetches a paginated list of jobs saved by the current user.
  ///
  /// [page] The page number (defaults to 1).
  /// [limit] The number of jobs per page (defaults to 10).
  /// Returns a list of saved [Job] entities on success, or a [Failure].
  Future<Either<Failure, List<Job>>> getSavedJobs({
    final int page = 1,
    final int limit = 10,
  });

  /// Adds a job to the current user's saved jobs list.
  ///
  /// [jobId] The ID of the job to save.
  /// Returns [Success] on successful operation, or a [Failure] on error.
  Future<Either<Failure, Success>> addSavedJob({required final int jobId});

  /// Deletes a job from the current user's saved jobs list.
  ///
  /// [jobId] The ID of the job to remove from saved list.
  /// Returns [Success] on successful operation, or a [Failure] on error.
  Future<Either<Failure, Success>> deleteSavedJob({required final int jobId});

  /// Fetches a paginated list of jobs the current user has applied for.
  ///
  /// [page] The page number (defaults to 1).
  /// [limit] The number of jobs per page (defaults to 10).
  /// Returns a list of applied [Job] entities on success, or a [Failure].
  Future<Either<Failure, List<Job>>> getAppliedJob({
    final int page = 1,
    final int limit = 10,
  });

  /// Submits a job application for the current user.
  ///
  /// [jobId] The ID of the job to apply for.
  /// [coverLetter] The cover letter text for the application.
  /// [cv] The [FileRequest] object containing the CV file data and name.
  /// Returns the [Job] entity of the applied job on success, or a [Failure].
  Future<Either<Failure, Job>> applyJob({
    required final int jobId,
    required final String coverLetter,
    required final FileRequest cv,
  });
}
