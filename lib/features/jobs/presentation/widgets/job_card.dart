import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/job.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.onPressed});

  final Job job;

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
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
                  Icon(IconlyLight.image, size: 48.0, color: Theme.of(context).colorScheme.primary),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(job.title), Text(job.company.name ?? '')],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Bookmark',
                    onPressed: () async {
                      // TODO(self): Implement bookmark functionality
                    },
                    icon: Icon(IconlyLight.bookmark, size: 24.0, color: Theme.of(context).colorScheme.primary),
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
                      Text('${DateTime(job.applicationDeadline.millisecond - job.postingDate.millisecond).day} days'),
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
