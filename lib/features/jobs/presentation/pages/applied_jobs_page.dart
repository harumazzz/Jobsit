import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../shared/routes/app_router.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

class AppliedJobsPage extends HookConsumerWidget {
  const AppliedJobsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final jobState = ref.read(applyJobControllerProvider);
      if (jobState is ApplyJobInitial) {
        await ref.read(applyJobControllerProvider.notifier).getJobApplied(page: 0);
      }
    });
    final page = useState(0);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 38.0,
            floating: true,
            backgroundColor: Color(0xFFefeff0),
            flexibleSpace: FlexibleSpaceBar(title: Text('Saved Jobs'), centerTitle: true),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: Consumer(
              builder: (context, ref, child) {
                final jobState = ref.watch(applyJobControllerProvider);
                switch (jobState) {
                  case ApplyJobInitial():
                  case ApplyJobLoading():
                    return SliverToBoxAdapter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (context, index) => const AppliedJobShimmerCard(),
                      ),
                    );
                  case ApplyJobError():
                    return SliverToBoxAdapter(
                      child: Center(child: Text(jobState.message, style: Theme.of(context).textTheme.bodyLarge)),
                    );
                  case ApplyJobLoaded():
                    final state = PagingState<int, Job>(
                      pages: [jobState.jobs],
                      keys: const [0],
                      hasNextPage: jobState.finished,
                    );
                    return PagedSliverList<int, Job>(
                      state: state,
                      fetchNextPage: () async {
                        final controller = ref.read(searchJobsControllerProvider.notifier);
                        if (ref.read(jobFilterControllerProvider.notifier).isEmpty) {
                          await controller.searchJobs(page: page.value, limit: 10);
                        } else {
                          final jobFilterState = ref.read(jobFilterControllerProvider) as JobFilterOnSearch;
                          await controller.filterJobs(
                            page: page.value,
                            limit: 10,
                            city: jobFilterState.city,
                            schedule: jobFilterState.schedule,
                            position: jobFilterState.position,
                            major: jobFilterState.major,
                            title: jobFilterState.title,
                          );
                        }
                        page.value++;
                      },
                      builderDelegate: PagedChildBuilderDelegate<Job>(
                        itemBuilder: (context, item, index) {
                          return AppliedJobCard(
                            job: item,
                            onPressed: () async {
                              final jobDetailState = ref.read(jobDetailControllerProvider.notifier);
                              await jobDetailState.getJobDetail(jobId: item.id);
                              if (context.mounted) {
                                await JobDetailRoute(id: item.id).push(context);
                              }
                            },
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
