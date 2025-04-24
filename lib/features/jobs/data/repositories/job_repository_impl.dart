import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/job_repository.dart';

@riverpod
JobRepository jobRepository(Ref ref) {
  return const JobRepositoryImpl();
}

class JobRepositoryImpl implements JobRepository {
  const JobRepositoryImpl();
}
