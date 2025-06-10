import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';

/// A card widget to display a summary of a job.
///
/// Includes job title, company name, logo, positions, location,
/// number of openings, and application deadline. Also features a bookmark
/// button to save/unsave the job.
class JobCard extends HookConsumerWidget {
  /// Creates a [JobCard].
  ///
  /// [job] The [Job] entity to display.
  /// [onPressed] Callback function executed when the card is tapped.
  const JobCard({super.key, required this.job, required this.onPressed});

  /// The job data to display on the card.
  final Job job;

  /// Callback function invoked when the card is tapped.
  final Future<void> Function() onPressed;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final savedJobState = ref.watch(savedJobControllerProvider);
    final isHighlighted =
        savedJobState is SavedJobLoaded &&
        savedJobState.jobs.containsKey(
          job.id,
        );
    final isBookmarkProcessing = useState(false);
    return Card(
      key: Key('job_card_${job.id}'),
      child: InkWell(
        key: Key('job_card_tap_${job.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            spacing: 8,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  if (job.company.logo != null)
                    _JobImage(job: job)
                  else
                    Icon(
                      IconlyLight.image,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(job.title), Text(job.company.name ?? '')],
                    ),
                  ),
                  _BookmarkButton(
                    key: Key('bookmark_button_${job.id}'),
                    job: job,
                    isBookmarkProcessing: isBookmarkProcessing,
                    ref: ref,
                    isHighlighted: isHighlighted,
                  ),
                ],
              ),
              if (job.positions.isNotEmpty)
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (final context, final index) => Chip(
                      label: Text(
                        job.positions[index].name,
                        // ignore: lines_longer_than_80_chars
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // ignore: lines_longer_than_80_chars
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.9,
                      ),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    separatorBuilder:
                        (
                          final context,
                          final index,
                        ) => const SizedBox(
                          width: 8,
                        ),
                    itemCount: job.positions.length,
                  ),
                ),
              Row(
                spacing: 8,
                children: [
                  Icon(
                    IconlyLight.location,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(job.address),
                ],
              ),
              const SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Icon(
                        IconlyLight.profile,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text('${job.amount}'),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Icon(
                        IconlyLight.timeCircle,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        // ignore: lines_longer_than_80_chars
                        '${DateTime.now().isBefore(job.applicationDeadline) ? job.applicationDeadline.difference(DateTime.now()).inDays : 0} ${context.t.common.days}',
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
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Job>('job', job))
      ..add(
        ObjectFlagProperty<Future<void> Function()>.has(
          'onPressed',
          onPressed,
        ),
      );
  }
}

/// A private button widget for bookmarking a job within a [JobCard].
///
/// Toggles the saved state of the job and provides visual feedback.
class _BookmarkButton extends StatelessWidget {
  /// Creates a [_BookmarkButton].
  ///
  /// [job] The job associated with this bookmark button.
  /// [isBookmarkProcessing] A [ValueNotifier] to track if a bookmark
  /// operation is in progress.
  /// [ref] The [WidgetRef] for Riverpod interactions.
  /// [isHighlighted] Boolean indicating if the job is currently bookmarked.
  const _BookmarkButton({
    super.key,
    required this.job,
    required this.isBookmarkProcessing,
    required this.ref,
    required this.isHighlighted,
  });

  /// The job to be bookmarked/unbookmarked.
  final Job job;

  /// Notifier to indicate if a bookmark operation is currently in progress.
  final ValueNotifier<bool> isBookmarkProcessing;

  /// Riverpod widget reference for interacting with providers.
  final WidgetRef ref;

  /// True if the job is currently bookmarked, false otherwise.
  final bool isHighlighted;

  @override
  Widget build(final BuildContext context) => IconButton(
    tooltip: context.t.common.save,
    onPressed: () async {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        if (ref.read(savedJobControllerProvider.notifier).contains(job.id)) {
          await ref
              .read(savedJobControllerProvider.notifier)
              .removeJob(
                jobId: job.id,
              );
          if (context.mounted) {
            NotificationService.success(
              context: context,
              message: context.t.job.unsaveSuccess,
            );
          }
        } else {
          await ref.read(savedJobControllerProvider.notifier).addJob(job: job);
          if (context.mounted) {
            NotificationService.success(
              context: context,
              message: context.t.job.saveSuccess,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          NotificationService.error(
            context: context,
            message: context.t.job.saveError,
          );
        }
      } finally {
        if (context.mounted) {
          isBookmarkProcessing.value = false;
        }
      }
    },
    icon: Icon(
      isHighlighted ? IconlyBold.bookmark : IconlyLight.bookmark,
      size: 24,
      color: Theme.of(context).colorScheme.primary,
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Job>('job', job))
      ..add(
        DiagnosticsProperty<ValueNotifier<bool>>(
          'isBookmarkProcessing',
          isBookmarkProcessing,
        ),
      )
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(DiagnosticsProperty<bool>('isHighlighted', isHighlighted));
  }
}

/// A shimmer loading placeholder widget for a [JobCard].
///
/// Displays a skeleton UI while job data is being fetched.
class ShimmerCard extends StatelessWidget {
  /// Creates a [ShimmerCard].
  const ShimmerCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer(
        interval: shimmerInterval,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Container(
                          width: 200,
                          height: 16,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 16,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 70,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                spacing: 8,
                children: [
                  Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 24,
                        height: 20,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
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

/// A widget to display a specific piece of job information with an icon.
///
/// Use to show items like position, job type, salary,
/// and deadline.
class JobIntroduce extends StatelessWidget {
  /// Creates a [JobIntroduce] widget.
  ///
  /// [title] The title or label for the piece of information.
  /// [content] The actual information content to display.
  /// [child] The icon widget to display alongside the information.
  const JobIntroduce({
    super.key,
    required this.title,
    required this.content,
    required this.child,
  });

  /// The title or label for the information (e.g., "Salary").
  final String title;

  /// The content of the information (e.g., "$1000 - $2000").
  final String content;

  /// The widget (typically an [Icon]) to display.
  final Widget child;

  @override
  Widget build(final BuildContext context) => Column(
    spacing: 5,
    children: [
      Container(
        width: 47,
        height: 47,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
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
        style:
            Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.w500,
            ),
        softWrap: true,
      ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(StringProperty('content', content));
  }
}

/// A private widget to display a job's company logo.
///
/// Uses [CachedNetworkImage] for efficient loading and placeholder/error handling.
class _JobImage extends StatelessWidget {
  /// Creates a [_JobImage].
  ///
  /// [job] The job whose company logo is to be displayed.
  const _JobImage({required this.job});

  /// The job entity containing company information, including the logo URL.
  final Job job;

  @override
  Widget build(final BuildContext context) => CachedNetworkImage(
    imageUrl: queryImage(job.company.logo!),
    width: 48,
    height: 48,
    fit: BoxFit.cover,
    placeholder: (final context, final url) => Shimmer(
      interval: const Duration(seconds: 5),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    errorWidget: (final context, final url, final error) => Icon(
      IconlyLight.image,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
  }
}

/// A card widget to display a summary of a job that the user has applied for.
///
/// Similar to [JobCard] but tailored for the "Applied Jobs" list,
/// potentially showing application status or date.
class AppliedJobCard extends StatelessWidget {
  /// Creates an [AppliedJobCard].
  ///
  /// [job] The [Job] entity to display.
  /// [onPressed] Callback function executed when the card is tapped.
  const AppliedJobCard({super.key, required this.job, required this.onPressed});

  /// The job data to display on the card.
  final Job job;

  /// Callback function invoked when the card is tapped.
  final Future<void> Function() onPressed;
  @override
  Widget build(final BuildContext context) => Card(
    key: Key('applied_job_card_${job.id}'),
    child: InkWell(
      key: Key('applied_job_card_tap_${job.id}'),
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (job.company.logo != null)
                  _JobImage(job: job)
                else
                  Icon(
                    IconlyLight.image,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(job.title), Text(job.company.name ?? '')],
                  ),
                ),
              ],
            ),
            if (job.positions.isNotEmpty)
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (final context, final index) => Chip(
                    label: Text(
                      job.positions[index].name,
                      // ignore: lines_longer_than_80_chars
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // ignore: lines_longer_than_80_chars
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.9,
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  separatorBuilder:
                      (
                        final context,
                        final index,
                      ) => const SizedBox(
                        width: 8,
                      ),
                  itemCount: job.positions.length,
                ),
              ),
            Row(
              spacing: 8,
              children: [
                Icon(
                  IconlyLight.location,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(job.address),
              ],
            ),
            const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    context.t.job.applied,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // ignore: lines_longer_than_80_chars
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(
                    alpha: 0.9,
                  ),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      IconlyLight.timeCircle,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      // ignore: lines_longer_than_80_chars
                      '${DateTime.now().isBefore(job.applicationDeadline) ? job.applicationDeadline.difference(DateTime.now()).inDays : 0} ${context.t.common.days}',
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

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Job>('job', job))
      ..add(
        ObjectFlagProperty<Future<void> Function()>.has(
          'onPressed',
          onPressed,
        ),
      );
  }
}

/// A shimmer loading placeholder widget for an [AppliedJobCard].
///
/// Displays a skeleton UI while applied job data is being fetched.
class AppliedJobShimmerCard extends StatelessWidget {
  /// Creates an [AppliedJobShimmerCard].
  const AppliedJobShimmerCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer(
        interval: const Duration(seconds: 5),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Container(
                          width: 200,
                          height: 16,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 16,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 70,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                spacing: 8,
                children: [
                  Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 24,
                        height: 20,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
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
