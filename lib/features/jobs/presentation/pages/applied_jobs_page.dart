import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

/// A page that displays a list of jobs the current user has applied for.
///
/// It uses infinite scrolling to load more applied jobs as the user scrolls.
/// It interacts with [applyJobControllerProvider] to fetch and display
/// the applied jobs.
class AppliedJobsPage extends HookConsumerWidget {
  /// Creates an [AppliedJobsPage].
  const AppliedJobsPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final jobState = ref.read(applyJobControllerProvider);
      if (jobState is ApplyJobInitial || jobState is ApplyJobError) {
        await ref
            .read(applyJobControllerProvider.notifier)
            .getJobApplied(
              page: 0,
            );
      }
    });
    final page = useState(0);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 38,
            floating: true,
            backgroundColor: const Color(0xFFefeff0),
            surfaceTintColor: const Color(0xFff5fafd),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(context.t.job.appliedJob),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: Consumer(
              builder: (final context, final ref, final child) {
                final jobState = ref.watch(applyJobControllerProvider);
                switch (jobState) {
                  case ApplyJobLoading():
                    return SliverToBoxAdapter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        // ignore: lines_longer_than_80_chars
                        itemBuilder: (final context, final index) => const AppliedJobShimmerCard(),
                      ),
                    );
                  case ApplyJobError():
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          context.t.job.appliedJobError,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  case ApplyJobLoaded():
                    if (jobState.jobs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            context.t.job.noAppliedJob,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }
                    final state = PagingState<int, Job>(
                      pages: [jobState.jobs],
                      keys: const [0],
                      hasNextPage: jobState.finished,
                    );
                    return PagedSliverList<int, Job>(
                      state: state,
                      fetchNextPage: () async {
                        final controller = ref.read(
                          searchJobsControllerProvider.notifier,
                        );
                        // ignore: lines_longer_than_80_chars
                        if (ref.read(jobFilterControllerProvider.notifier).isEmpty()) {
                          await controller.searchJobs(
                            page: page.value,
                            limit: 10,
                          );
                        } else {
                          // ignore: lines_longer_than_80_chars
                          final jobFilterState = ref.read(jobFilterControllerProvider) as JobFilterOnSearch;
                          await controller.filterJobs(
                            page: page.value,
                            limit: 10,
                            city: jobFilterState.city,
                            schedules: jobFilterState.schedulesList,
                            positions: jobFilterState.positionsList,
                            majors: jobFilterState.majorsList,
                            title: jobFilterState.title,
                          );
                        }
                        page.value++;
                      },
                      builderDelegate: PagedChildBuilderDelegate<Job>(
                        itemBuilder:
                            // ignore: lines_longer_than_80_chars
                            (final context, final item, final index) => AppliedJobCard(
                              job: item,
                              onPressed: () async {
                                final jobDetailState = ref.read(
                                  jobDetailControllerProvider.notifier,
                                );
                                await jobDetailState.getJobDetail(
                                  jobId: item.id,
                                );
                                if (context.mounted) {
                                  await JobDetailRoute(id: item.id).push(
                                    context,
                                  );
                                }
                              },
                            ),
                      ),
                    );
                  default:
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
