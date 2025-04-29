import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

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
                      children: [Text(job.title), Text(job.company.name)],
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
    final placeholderColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: [
            Row(
              spacing: 16.0,
              children: [
                Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8.0)),
                  child: Center(child: Icon(IconlyLight.image, color: placeholderColor, size: 32.0)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.0,
                    children: [
                      _ShimmerPlaceholder(width: 200, height: 24.0, borderRadius: 4.0, color: placeholderColor),
                      _ShimmerPlaceholder(width: 150, height: 16.0, borderRadius: 4.0, color: placeholderColor),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              spacing: 8.0,
              children: [
                Icon(IconlyLight.location, color: placeholderColor, size: 24.0),
                _ShimmerPlaceholder(width: 200, height: 16.0, borderRadius: 4.0, color: placeholderColor),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16.0)),
                  child: _ShimmerPlaceholder(width: 60, height: 16.0, borderRadius: 4.0, color: placeholderColor),
                ),
                Row(
                  spacing: 8.0,
                  children: [
                    Icon(IconlyLight.timeSquare, color: placeholderColor, size: 24.0),
                    _ShimmerPlaceholder(width: 80, height: 16.0, borderRadius: 4.0, color: placeholderColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(borderRadius)),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('borderRadius', borderRadius));
    properties.add(ColorProperty('color', color));
  }
}
