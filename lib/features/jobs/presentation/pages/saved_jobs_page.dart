import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

/// A page that displays a list of jobs saved by the current user.
///
/// It uses infinite scrolling to load more saved jobs as the user scrolls.
/// It interacts with [savedJobControllerProvider] to fetch and display
/// the saved jobs.
class SavedJobsPage extends HookWidget {
  /// Creates a [SavedJobsPage].
  const SavedJobsPage({super.key});

  @override
  Widget build(final BuildContext context) {
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
              title: Text(context.t.job.savedJob),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: Consumer(
              builder: (final context, final ref, final child) {
                final jobState = ref.watch(savedJobControllerProvider);
                switch (jobState) {
                  case SavedJobLoading():
                    return SliverToBoxAdapter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        // ignore: lines_longer_than_80_chars
                        itemBuilder: (final context, final index) => const ShimmerCard(),
                      ),
                    );
                  case SavedJobError():
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  case SavedJobLoaded():
                    if (jobState.jobs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            context.t.job.noSavedJob,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }
                    final state = PagingState<int, Job>(
                      pages: [jobState.jobs.values.toList()],
                      keys: const [0],
                      hasNextPage: jobState.finished,
                    );
                    return PagedSliverList<int, Job>(
                      state: state,
                      fetchNextPage: () async {
                        // ignore: lines_longer_than_80_chars
                        final controller = ref.read(savedJobControllerProvider.notifier);
                        if (!jobState.finished) {
                          await controller.getSavedJobs();
                          page.value++;
                        }
                      },
                      builderDelegate: PagedChildBuilderDelegate<Job>(
                        itemBuilder:
                            (final context, final item, final index) => JobCard(
                              job: item,
                              onPressed: () async {
                                // ignore: lines_longer_than_80_chars
                                final jobDetailState = ref.read(jobDetailControllerProvider.notifier);
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
                        // ignore: lines_longer_than_80_chars
                        newPageProgressIndicatorBuilder: (final context) => const SizedBox.shrink(),
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
