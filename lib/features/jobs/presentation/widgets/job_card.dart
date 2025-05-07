import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/network/api_constant.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';

class JobCard extends ConsumerWidget {
  const JobCard({super.key, required this.job, required this.onPressed});

  final Job job;

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedJobState = ref.watch(savedJobControllerProvider);
    final isHighlighted = savedJobState is SavedJobLoaded && savedJobState.jobs.containsKey(job.id);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            spacing: 8.0,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.0,
                children: [
                  job.company.logo != null
                      ? CachedNetworkImage(
                        imageUrl: queryImage(job.company.logo!),
                        width: 48.0,
                        height: 48.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Icon(IconlyLight.image, size: 48.0, color: Theme.of(context).colorScheme.primary);
                        },
                      )
                      : Icon(IconlyLight.image, size: 48.0, color: Theme.of(context).colorScheme.primary),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(job.title), Text(job.company.name ?? '')],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Bookmark',
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      if (ref.read(savedJobControllerProvider.notifier).contains(job.id)) {
                        await ref.read(savedJobControllerProvider.notifier).removeJob(jobId: job.id);
                      } else {
                        await ref.read(savedJobControllerProvider.notifier).addJob(job: job);
                      }
                    },
                    icon: Icon(
                      isHighlighted ? IconlyBold.bookmark : IconlyLight.bookmark,
                      size: 24.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 8.0,
                children: [
                  ...job.positions.map(
                    (position) => Chip(
                      label: Text(
                        position.name,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 8.0,
                children: [
                  Icon(IconlyLight.location, size: 24.0, color: Theme.of(context).colorScheme.primary),
                  Text(job.address),
                ],
              ),
              const SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 8.0,
                    children: [
                      Icon(IconlyLight.profile, size: 24.0, color: Theme.of(context).colorScheme.primary),
                      Text('${job.amount}'),
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      Icon(IconlyLight.timeCircle, size: 24.0, color: Theme.of(context).colorScheme.primary),
                      Text(
                        '${DateTime.now().isBefore(job.applicationDeadline) ? job.applicationDeadline.difference(DateTime.now()).inDays : 0} days',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
    properties.add(ObjectFlagProperty<Future<void> Function()>.has('onPressed', onPressed));
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 16.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.0,
                      children: [
                        Container(
                          width: 200,
                          height: 16.0,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
                        ),
                        Container(
                          width: 150,
                          height: 16.0,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 24.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0)),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    width: 70,
                    height: 24.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0)),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    width: 50,
                    height: 24.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0)),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                spacing: 8.0,
                children: [
                  Container(
                    width: 24.0,
                    height: 16.0,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  Container(
                    width: 200,
                    height: 16.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 20.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0)),
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      Container(
                        width: 24.0,
                        height: 20.0,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                      Container(
                        width: 80,
                        height: 16.0,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobIntroduce extends StatelessWidget {
  const JobIntroduce({super.key, required this.title, required this.content, required this.child});

  final String title;

  final String content;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5.0,
      children: [
        Container(
          width: 47.0,
          height: 47.0,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.onPrimary),
          child: child,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          content,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w500,
          ),
          softWrap: true,
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('content', content));
  }
}
