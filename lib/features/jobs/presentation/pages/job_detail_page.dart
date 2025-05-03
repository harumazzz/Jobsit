import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/job_provider.dart';

class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 38.0,
            floating: true,
            backgroundColor: const Color(0xFFefeff0),
            flexibleSpace: const FlexibleSpaceBar(title: Text('Job Detail'), centerTitle: true),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(jobDetailControllerProvider);
                  return switch (state) {
                    JobDetailLoading _ => const Center(child: CircularProgressIndicator()),
                    JobDetailError _ => const SizedBox.shrink(),
                    JobDetailInitial _ => const SizedBox.shrink(),
                    JobDetailLoaded _ => IconButton(
                      icon: const Icon(IconlyLight.bookmark),
                      tooltip: 'Bookmark',
                      iconSize: 30.0,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        // TODO(self): Implement bookmark functionality
                      },
                    ),
                  };
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 12.0,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(jobDetailControllerProvider);
                      return switch (state) {
                        JobDetailError _ => const SizedBox.shrink(),
                        JobDetailInitial _ => const SizedBox.shrink(),
                        JobDetailLoading _ => Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                          highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Container(
                            width: 200,
                            height: 16.0,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
                          ),
                        ),
                        JobDetailLoaded it => Text(it.job.title, style: Theme.of(context).textTheme.titleLarge),
                      };
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 12.0,
                    children: [
                      Text('Company Name', style: Theme.of(context).textTheme.titleLarge),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 8.0,
                        children: [
                          Icon(IconlyLight.location, size: 24.0, color: Theme.of(context).colorScheme.primary),
                          Text('Location', style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Text('Job Description', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _ApplyNavBar(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

class _ApplyNavBar extends StatelessWidget {
  const _ApplyNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0)),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(jobDetailControllerProvider);
          return switch (state) {
            JobDetailLoading _ => const Center(child: CircularProgressIndicator()),
            JobDetailError _ => const SizedBox.shrink(),
            JobDetailInitial _ => const SizedBox.shrink(),
            JobDetailLoaded _ => ElevatedButton(
              onPressed: () async {
                // TODO(self): Implement apply functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ),
              child: const Text('Apply Now', style: TextStyle(color: Colors.white)),
            ),
          };
        },
      ),
    );
  }
}
