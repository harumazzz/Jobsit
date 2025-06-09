import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

/// Enum representing the tabs available on the job detail page.
enum _JobTabType {
  /// Tab for displaying the job description.
  description,

  /// Tab for displaying company information.
  company,
}

/// A page that displays detailed information about a specific job.
///
/// It fetches job details using [jobDetailControllerProvider] based on the
/// provided [jobId]. It includes sections for job description, company info,
/// related jobs, and allows users to save/unsave the job and apply for it.
class JobDetailPage extends HookConsumerWidget {
  /// Creates a [JobDetailPage].
  ///
  /// [jobId] The unique identifier of the job to display.
  const JobDetailPage({super.key, required this.jobId});

  /// The ID of the job whose details are to be displayed.
  final int jobId;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final pageController = usePageController();
    final isSelected = useState(
      ref.read(savedJobControllerProvider.notifier).contains(jobId),
    );
    final selectedTabIndex = useState(_JobTabType.description.index);
    final isBookmarkProcessing = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(jobDetailControllerProvider.notifier)
            .getJobDetail(
              jobId: jobId,
            );
      });
      return null;
    }, [jobId]);

    return Scaffold(
      backgroundColor: const Color(0xFff5fafd),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 38,
            floating: true,
            backgroundColor: const Color(0xFff5fafd),
            surfaceTintColor: const Color(0xFff5fafd),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(context.t.job.jobDetail),
              centerTitle: true,
            ),
            actions: [
              _BookmarkButton(
                key: const Key('job_detail_bookmark_button'),
                jobId: jobId,
                isSelected: isSelected,
                isBookmarkProcessing: isBookmarkProcessing,
              ),
            ],
          ),
          Consumer(
            builder: (final context, final ref, final child) {
              final state = ref.watch(jobDetailControllerProvider);
              return switch (state) {
                JobDetailLoading() => const SliverToBoxAdapter(
                  child: JobDetailShimmerCard(),
                ),
                JobDetailError() => SliverFillRemaining(
                  child: Center(child: Text(context.t.job.detailError)),
                ),
                JobDetailInitial() => SliverFillRemaining(
                  child: Center(child: Text(context.t.job.detailError)),
                ),
                // ignore: lines_longer_than_80_chars
                JobDetailLoaded(job: final job, relatedJobs: final relatedJobs) => SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        if (job.company.logo != null)
                          _JobImage(job: job)
                        else
                          Icon(
                            IconlyLight.image,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          job.title,
                          // ignore: lines_longer_than_80_chars
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          job.company.name ?? '',
                          // ignore: lines_longer_than_80_chars
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              IconlyLight.location,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.company.location ?? '',
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    // ignore: lines_longer_than_80_chars
                                    color: Theme.of(context).colorScheme.onSecondary,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...job.majors.map(
                              (final major) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  major.name,
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.labelLarge?.copyWith(
                                        // ignore: lines_longer_than_80_chars
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _JobDisplay(job: job),
                        const SizedBox(height: 24),
                        _JobTabs(
                          key: const Key('job_detail_tabs'),
                          pageController: pageController,
                          selectedTabIndex: selectedTabIndex,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          height: 700,
                          child: PageView(
                            controller: pageController,
                            onPageChanged: (final index) async {
                              selectedTabIndex.value = index;
                            },
                            children: [
                              _JobDescription(job: job),
                              _JobInfo(
                                job: job,
                                relatedJobs: relatedJobs,
                                onPressed: (final job) async {
                                  JobDetailRoute(id: job.id).pushReplacement(
                                    context,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              };
            },
          ),
        ],
      ),
      bottomNavigationBar: _ApplyNavBar(
        key: const Key('job_apply_nav_bar'),
        jobId: jobId,
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

/// Widget to display company information and related jobs.
class _JobInfo extends StatelessWidget {
  /// Creates a [_JobInfo] widget.
  ///
  /// [job] The job entity containing company details.
  /// [relatedJobs] A list of jobs related to the current one.
  /// [onPressed] Callback function when a related job card is pressed.
  const _JobInfo({
    required this.job,
    required this.relatedJobs,
    required this.onPressed,
  });

  /// The main job object, used to display company information.
  final Job job;

  /// Callback invoked when a related job card is tapped.
  final Future<void> Function(Job job) onPressed;

  /// A list of jobs related to the current [job].
  final List<Job> relatedJobs;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.t.common.companyOverview,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Flexible(
        child: Text(
          job.company.description ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        context.t.common.companyAddress,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Icon(
            IconlyLight.location,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            job.company.location ?? '',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        context.t.common.otherJobs,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      if (relatedJobs.isEmpty)
        SizedBox(
          height: 220,
          child: Center(
            child: Text(
              context.t.common.noOtherJobs,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      else
        CarouselSlider(
          options: CarouselOptions(height: 220, autoPlay: true),
          items: [
            ...relatedJobs.map(
              (final e) => JobCard(job: e, onPressed: () async => onPressed(e)),
            ),
          ],
        ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Job>('job', job))
      ..add(IterableProperty<Job>('relatedJobs', relatedJobs))
      ..add(
        ObjectFlagProperty<Future<void> Function(Job job)>.has(
          'onPressed',
          onPressed,
        ),
      );
  }
}

/// Widget to display the detailed description of a job.
class _JobDescription extends StatelessWidget {
  /// Creates a [_JobDescription] widget.
  ///
  /// [job] The job entity whose description is to be displayed.
  const _JobDescription({required this.job});

  /// The job object containing the description.
  final Job job;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.t.common.jobDescription,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        job.description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
  }
}

/// Widget for rendering the tab bar (Description, Company) on the job detail
///
/// Manages tab selection and updates the [PageController] to switch views.
class _JobTabs extends StatelessWidget {
  /// Creates a [_JobTabs] widget.
  ///
  /// [selectedTabIndex] A [ValueNotifier] holding the index of the currently
  /// selected tab.  /// [pageController] The [PageController] used to switch between tab content.
  const _JobTabs({
    super.key,
    required this.selectedTabIndex,
    required this.pageController,
  });

  /// Notifier for the currently selected tab index.
  final ValueNotifier<int> selectedTabIndex;

  /// Controller for the [PageView] that displays tab content.
  final PageController pageController;

  @override
  Widget build(final BuildContext context) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          key: const Key('job_detail_description_tab'),
          onTap: () async {
            selectedTabIndex.value = _JobTabType.description.index;
            pageController.jumpToPage(_JobTabType.description.index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              // ignore: lines_longer_than_80_chars
              color: selectedTabIndex.value == _JobTabType.description.index ? Colors.white : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withAlpha(0xCC),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              context.t.common.description,
              style: TextStyle(
                fontWeight:
                    // ignore: lines_longer_than_80_chars
                    selectedTabIndex.value == _JobTabType.description.index ? FontWeight.bold : FontWeight.normal,
                color: selectedTabIndex.value == _JobTabType.description.index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: GestureDetector(
          key: const Key('job_detail_company_tab'),
          onTap: () async {
            selectedTabIndex.value = _JobTabType.company.index;
            pageController.jumpToPage(_JobTabType.company.index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              // ignore: lines_longer_than_80_chars
              color: selectedTabIndex.value == _JobTabType.company.index ? Colors.white : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withAlpha(0xCC),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              context.t.common.company,
              style: TextStyle(
                // ignore: lines_longer_than_80_chars
                fontWeight: selectedTabIndex.value == _JobTabType.company.index ? FontWeight.bold : FontWeight.normal,
                color: selectedTabIndex.value == _JobTabType.company.index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ),
      ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<int>>(
          'selectedTabIndex',
          selectedTabIndex,
        ),
      )
      ..add(
        DiagnosticsProperty<PageController>(
          'pageController',
          pageController,
        ),
      );
  }
}

/// Widget to display key job attributes like position, type, salary.
class _JobDisplay extends StatelessWidget {
  /// Creates a [_JobDisplay] widget.
  ///
  /// [job] The job entity whose attributes are to be displayed.
  const _JobDisplay({required this.job});

  /// The job object containing details like position, schedule, salary, etc.
  final Job job;

  @override
  Widget build(final BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      JobIntroduce(
        title: context.t.job.position,
        content: job.positions.isNotEmpty ? job.positions[0].name : '',
        child: Icon(
          IconlyLight.profile,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      JobIntroduce(
        title: context.t.job.type,
        content: job.schedules.isNotEmpty ? job.schedules[0].name : ' ',
        child: Icon(
          IconlyLight.work,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      JobIntroduce(
        title: context.t.job.salary,
        content: '\$${job.minInUSD} - \$${job.maxInUSD}',
        child: Icon(
          IconlyLight.wallet,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      JobIntroduce(
        title: context.t.job.deadline,
        content: DateFormat('dd/MM/yy').format(job.applicationDeadline.toLocal()),
        child: Icon(
          IconlyLight.calendar,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
  }
}

/// Widget to display the company logo for a job.
///
/// Uses [CachedNetworkImage] for efficient image loading and caching.
/// Shows a placeholder shimmer effect while loading and an error failure.
class _JobImage extends StatelessWidget {
  /// Creates a [_JobImage] widget.
  ///
  /// [job] The job entity containing the company logo URL.
  const _JobImage({required this.job});

  /// The job object, used to access the company logo.
  final Job job;

  @override
  Widget build(final BuildContext context) => Container(
    alignment: Alignment.center,
    width: 86,
    height: 86,
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: CachedNetworkImage(
      imageUrl: queryImage(job.company.logo!),
      fit: BoxFit.contain,
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
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
  }
}

/// A button widget for bookmarking (saving/unsaving) a job.
///
/// Interacts with [savedJobControllerProvider] to manage the saved state.
/// Displays a different icon based on whether the job is currently saved.
class _BookmarkButton extends StatelessWidget {
  /// Creates a [_BookmarkButton].
  ///
  /// [jobId] The ID of the job to be bookmarked.
  /// [isSelected] A [ValueNotifier] indicating if the job is currently selected
  /// (saved).
  /// [isBookmarkProcessing] A [ValueNotifier] to track if a bookmark operation
  /// is in progress to prevent multiple rapid clicks.
  const _BookmarkButton({
    super.key,
    required this.jobId,
    required this.isSelected,
    required this.isBookmarkProcessing,
  });

  /// The ID of the job associated with this bookmark button.
  final int jobId;

  /// Notifier for the selection state of the bookmark.
  final ValueNotifier<bool> isSelected;

  /// Notifier to indicate if a bookmark operation is currently in progress.
  final ValueNotifier<bool> isBookmarkProcessing;

  @override
  Widget build(final BuildContext context) => Consumer(
    builder: (final context, final ref, final child) {
      final state = ref.watch(jobDetailControllerProvider);
      return switch (state) {
        JobDetailLoading() => const SizedBox(width: 30, height: 30),
        JobDetailError() => const SizedBox.shrink(),
        JobDetailInitial() => const SizedBox.shrink(),
        JobDetailLoaded(job: final job) => IconButton(
          icon: Icon(
            isSelected.value ? IconlyBold.bookmark : IconlyLight.bookmark,
          ),
          tooltip: context.t.common.save,
          iconSize: 30,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            if (isBookmarkProcessing.value) {
              return;
            }
            isBookmarkProcessing.value = true;
            try {
              isSelected.value = !isSelected.value;
              if (ref
                  .read(savedJobControllerProvider.notifier)
                  .contains(
                    state.job.id,
                  )) {
                await ref
                    .read(savedJobControllerProvider.notifier)
                    .removeJob(
                      jobId: jobId,
                    );
                if (context.mounted) {
                  NotificationService.success(
                    context: context,
                    message: context.t.job.unsaveSuccess,
                  );
                }
              } else {
                await ref
                    .read(savedJobControllerProvider.notifier)
                    .addJob(
                      job: job,
                    );
                if (context.mounted) {
                  NotificationService.success(
                    context: context,
                    message: context.t.job.saveSuccess,
                  );
                }
              }
            } finally {
              isBookmarkProcessing.value = false;
            }
          },
        ),
      };
    },
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ValueNotifier<bool>>('isSelected', isSelected))
      ..add(
        DiagnosticsProperty<ValueNotifier<bool>>(
          'isBookmarkProcessing',
          isBookmarkProcessing,
        ),
      )
      ..add(IntProperty('jobId', jobId));
  }
}

/// The bottom navigation bar for the job detail page, primarily containing
/// the "Apply" button.
class _ApplyNavBar extends StatelessWidget {
  /// Creates an [_ApplyNavBar].
  ///
  /// [jobId] The ID of the job for which the apply action is relevant.
  const _ApplyNavBar({super.key, required this.jobId});

  /// The ID of the job to apply for.
  final int jobId;

  @override
  Widget build(final BuildContext context) => SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Consumer(
        builder: (final context, final ref, final child) {
          final state = ref.watch(jobDetailControllerProvider);
          return switch (state) {
            JobDetailLoading() => const JobDetailNavBarShimmer(),
            JobDetailError() => const SizedBox.shrink(),
            JobDetailInitial() => const SizedBox.shrink(),
            JobDetailLoaded() => ElevatedButton(
              key: const Key('job_apply_button'),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (final context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: _ApplyModal(jobId: jobId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 32,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              child: Text(
                context.t.common.apply,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          };
        },
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

/// A modal bottom sheet widget for the job application process.
///
/// Allows users to attach a CV and write a cover letter.
class _ApplyModal extends HookWidget {
  /// Creates an [_ApplyModal].
  ///
  /// [jobId] The ID of the job being applied for.
  const _ApplyModal({required this.jobId});

  /// The ID of the job for which the application is being made.
  final int jobId;

  @override
  Widget build(final BuildContext context) {
    final file = useState<FileSelectorResult?>(null);
    final controller = useTextEditingController();
    final text = useState<String>(context.t.job.uploadNewCV);
    return SafeArea(
      child: Container(
        height: 560,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t.job.attachCV,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (final context, final ref, final child) => TextButton(
                  key: const Key('cv_upload_button'),
                  style: TextButton.styleFrom(
                    // ignore: lines_longer_than_80_chars
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      text.value,
                      // ignore: lines_longer_than_80_chars
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    // ignore: lines_longer_than_80_chars
                    final result = await ref.read(fileServiceProvider).uploadFile([
                      const FileSelector(label: 'CV', extensions: ['pdf']),
                    ]);
                    result.fold(
                      ifLeft: (_) => null,
                      ifRight: (final e) {
                        if (e.data.length > 512 * 1024) {
                          NotificationService.error(
                            context: context,
                            message: context.t.validation.file.cvFormat,
                          );
                          return;
                        }
                        text.value = e.name;
                        file.value = e;
                      },
                    );
                  },
                ),
              ),
              if (file.value != null) PreviewButton(file: file),
              const SizedBox(height: 16),
              Text(
                context.t.common.resumeLetter.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('cover_letter_field'),
                controller: controller,
                minLines: 5,
                maxLines: 5,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  hintText: context.t.common.resumeLetter.description,
                  hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary.withAlpha(
                      0x80,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ApplyButton(jobId: jobId, file: file, controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

/// The "Apply" button within the [_ApplyModal].
///
/// Handles the logic for submitting the job application, including CV and
/// cover letter, by interacting with [applyJobControllerProvider].
class _ApplyButton extends StatelessWidget {
  /// Creates an [_ApplyButton].
  ///
  /// [jobId] The ID of the job to apply for.
  /// [file] A [ValueNotifier] holding the selected CV file.
  /// [controller] The [TextEditingController] for the cover letter.
  const _ApplyButton({
    required this.jobId,
    required this.file,
    required this.controller,
  });

  /// The ID of the job being applied to.
  final int jobId;

  /// Notifier holding the selected CV file information.
  final ValueNotifier<FileSelectorResult?> file;

  /// Controller for the cover letter text field.
  final TextEditingController controller;

  @override
  Widget build(final BuildContext context) => Consumer(
    builder: (final context, final ref, final child) => CustomButton(
      key: const Key('submit_application_button'),
      onPressed: () async {
        if (file.value == null) {
          NotificationService.error(
            context: context,
            message: context.t.validation.required.cv,
          );
          return;
        }
        if (controller.text.trim().isEmpty) {
          NotificationService.error(
            context: context,
            message: context.t.job.noReferenceLetter,
          );
          return;
        }
        await ref
            .read(applyJobControllerProvider.notifier)
            .applyJob(
              jobId: jobId,
              referenceLetter: controller.text,
              cv: file.value!,
            );
        final state = ref.read(applyJobControllerProvider);
        if (state is ApplyJobError) {
          if (context.mounted) {
            NotificationService.error(
              context: context,
              message: context.t.job.appliedJob,
            );
          }
        } else if (state is ApplyJobLoaded) {
          if (context.mounted) {
            NotificationService.success(
              context: context,
              message: context.t.job.applicationSuccess,
            );
            Navigator.pop(context);
          }
        }
      },
      child: Center(
        child: Text(
          context.t.common.apply,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('jobId', jobId))
      ..add(
        DiagnosticsProperty<ValueNotifier<FileSelectorResult?>>('file', file),
      )
      ..add(
        DiagnosticsProperty<TextEditingController>('controller', controller),
      );
  }
}

/// A shimmer loading placeholder widget for the job detail card.
///
/// Displays a skeleton UI while job details are being fetched.
class JobDetailShimmerCard extends StatelessWidget {
  /// Creates a [JobDetailShimmerCard].
  const JobDetailShimmerCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Company Logo
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Container(
              alignment: Alignment.center,
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: shimmerColor,
                border: Border.all(color: Colors.grey[400]!, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (final index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(5),
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Job Display Cards (Salary, Exp, etc.)
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                3,
                (final index) => _ShimmerLoader(shimmerColor: shimmerColor),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tab Indicators
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content Area
          Shimmer(
            interval: const Duration(seconds: 5),
            child: Column(
              children: List.generate(
                5,
                (final index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerLoader extends StatelessWidget {
  const _ShimmerLoader({
    super.key,
    required this.shimmerColor,
  });

  final Color shimmerColor;

  @override
  Widget build(final BuildContext context) => Column(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: shimmerColor,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: 60,
        height: 12,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: 80,
        height: 16,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('shimmerColor', shimmerColor));
  }
}

/// A shimmer loading placeholder widget for the bottom navigation bar
/// on the job detail page.
class JobDetailNavBarShimmer extends StatelessWidget {
  /// Creates a [JobDetailNavBarShimmer].
  const JobDetailNavBarShimmer({super.key});

  @override
  Widget build(final BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Shimmer(
          interval: const Duration(seconds: 5),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
