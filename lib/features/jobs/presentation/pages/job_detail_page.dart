import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

enum _JobTabType { description, company }

class JobDetailPage extends HookConsumerWidget {
  const JobDetailPage({super.key, required this.jobId});

  final int jobId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final isSelected = useState(ref.read(savedJobControllerProvider.notifier).contains(jobId));
    final selectedTabIndex = useState(_JobTabType.description.index);
    final isBookmarkProcessing = useState(false);

    return Scaffold(
      backgroundColor: const Color(0xFff5fafd),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 38.0,
            floating: true,
            backgroundColor: const Color(0xFff5fafd),
            surfaceTintColor: const Color(0xFff5fafd),
            flexibleSpace: const FlexibleSpaceBar(title: Text('Job Detail'), centerTitle: true),
            actions: [
              _BookmarkButton(jobId: jobId, isSelected: isSelected, isBookmarkProcessing: isBookmarkProcessing),
            ],
          ),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(jobDetailControllerProvider);
              return switch (state) {
                JobDetailLoading() => const SliverToBoxAdapter(child: JobDetailShimmerCard()),
                JobDetailError() => SliverFillRemaining(child: Center(child: Text(context.t.job.detailError))),
                JobDetailInitial() => SliverFillRemaining(child: Center(child: Text(context.t.job.detailError))),
                JobDetailLoaded(job: final job, relatedJobs: final relatedJobs) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16.0),
                        job.company.logo != null
                            ? _JobImage(job: job)
                            : Icon(IconlyLight.image, size: 48.0, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16.0),
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          job.company.name ?? '',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(IconlyLight.location, size: 24.0, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4.0),
                            Text(
                              job.company.location ?? '',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...job.majors.map(
                              (major) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Text(
                                  major.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        _JobDisplay(job: job),
                        const SizedBox(height: 24.0),
                        _JobTabs(pageController: pageController, selectedTabIndex: selectedTabIndex),
                        const SizedBox(height: 24.0),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          height: 700,
                          child: PageView(
                            controller: pageController,
                            onPageChanged: (index) async {
                              selectedTabIndex.value = index;
                            },
                            children: [
                              _JobDescription(job: job),
                              _JobInfo(
                                job: job,
                                relatedJobs: relatedJobs,
                                onPressed: (job) async {
                                  if (context.mounted) {
                                    JobDetailRoute(id: job.id).pushReplacement(context);
                                  }
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  final jobDetailState = ref.read(jobDetailControllerProvider.notifier);
                                  await jobDetailState.getJobDetail(jobId: job.id);
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
      bottomNavigationBar: _ApplyNavBar(jobId: jobId),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

class _JobInfo extends StatelessWidget {
  const _JobInfo({required this.job, required this.relatedJobs, required this.onPressed});

  final Job job;

  final Future<void> Function(Job job) onPressed;

  final List<Job> relatedJobs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.common.companyOverview,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Flexible(
          child: Text(
            job.company.description ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          context.t.common.companyAddress,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Icon(IconlyLight.location, size: 24.0, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8.0),
            Text(
              job.company.location ?? '',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Text(
          context.t.common.otherJobs,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        relatedJobs.isEmpty
            ? SizedBox(
              height: 220.0,
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
            : CarouselSlider(
              options: CarouselOptions(height: 220.0, autoPlay: true),
              items: [
                ...relatedJobs.map((e) {
                  return JobCard(job: e, onPressed: () async => onPressed(e));
                }),
              ],
            ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
    properties.add(IterableProperty<Job>('relatedJobs', relatedJobs));
    properties.add(ObjectFlagProperty<Future<void> Function(Job job)>.has('onPressed', onPressed));
  }
}

class _JobDescription extends StatelessWidget {
  const _JobDescription({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.common.jobDescription,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Text(
          job.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
  }
}

class _JobTabs extends StatelessWidget {
  const _JobTabs({required this.selectedTabIndex, required this.pageController});

  final ValueNotifier<int> selectedTabIndex;

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              selectedTabIndex.value = _JobTabType.description.index;
              pageController.jumpToPage(_JobTabType.description.index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: selectedTabIndex.value == _JobTabType.description.index ? Colors.white : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  bottomLeft: Radius.circular(12.0),
                ),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8)),
              ),
              alignment: Alignment.center,
              child: Text(
                context.t.common.description,
                style: TextStyle(
                  fontWeight:
                      selectedTabIndex.value == _JobTabType.description.index ? FontWeight.bold : FontWeight.normal,
                  color:
                      selectedTabIndex.value == _JobTabType.description.index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              selectedTabIndex.value = _JobTabType.company.index;
              pageController.jumpToPage(_JobTabType.company.index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: selectedTabIndex.value == _JobTabType.company.index ? Colors.white : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8)),
              ),
              alignment: Alignment.center,
              child: Text(
                context.t.common.company,
                style: TextStyle(
                  fontWeight: selectedTabIndex.value == _JobTabType.company.index ? FontWeight.bold : FontWeight.normal,
                  color:
                      selectedTabIndex.value == _JobTabType.company.index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ValueNotifier<int>>('selectedTabIndex', selectedTabIndex));
    properties.add(DiagnosticsProperty<PageController>('pageController', pageController));
  }
}

class _JobDisplay extends StatelessWidget {
  const _JobDisplay({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        JobIntroduce(
          title: context.t.job.position,
          content: job.positions.isNotEmpty ? job.positions[0].name : '',
          child: Icon(IconlyLight.profile, size: 24.0, color: Theme.of(context).colorScheme.primary),
        ),
        JobIntroduce(
          title: context.t.job.type,
          content: job.schedules.isNotEmpty ? job.schedules[0].name : ' ',
          child: Icon(IconlyLight.work, size: 24.0, color: Theme.of(context).colorScheme.primary),
        ),
        JobIntroduce(
          title: context.t.job.salary,
          content: '\$${job.minInUSD} - \$${job.maxInUSD}',
          child: Icon(IconlyLight.wallet, size: 24.0, color: Theme.of(context).colorScheme.primary),
        ),
        JobIntroduce(
          title: context.t.job.deadline,
          content: DateFormat('dd/MM/yy').format(job.applicationDeadline.toLocal()),
          child: Icon(IconlyLight.calendar, size: 24.0, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
  }
}

class _JobImage extends StatelessWidget {
  const _JobImage({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 86.0,
      height: 86.0,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: CachedNetworkImage(
        imageUrl: queryImage(job.company.logo!),
        fit: BoxFit.contain,
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
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Job>('job', job));
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.jobId, required this.isSelected, required this.isBookmarkProcessing});

  final int jobId;

  final ValueNotifier<bool> isSelected;

  final ValueNotifier<bool> isBookmarkProcessing;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(jobDetailControllerProvider);
        return switch (state) {
          JobDetailLoading() => const SizedBox(width: 30, height: 30),
          JobDetailError() => const SizedBox.shrink(),
          JobDetailInitial() => const SizedBox.shrink(),
          JobDetailLoaded(job: final job) => IconButton(
            icon: Icon(isSelected.value ? IconlyBold.bookmark : IconlyLight.bookmark),
            tooltip: context.t.common.save,
            iconSize: 30.0,
            color: Theme.of(context).colorScheme.primary,
            onPressed: () async {
              if (isBookmarkProcessing.value) {
                return;
              }
              isBookmarkProcessing.value = true;
              try {
                isSelected.value = !isSelected.value;
                if (ref.read(savedJobControllerProvider.notifier).contains(state.job.id)) {
                  await ref.read(savedJobControllerProvider.notifier).removeJob(jobId: jobId);
                  if (context.mounted) {
                    NotificationService.success(context: context, message: context.t.job.unsaveSuccess);
                  }
                } else {
                  await ref.read(savedJobControllerProvider.notifier).addJob(job: job);
                  if (context.mounted) {
                    NotificationService.success(context: context, message: context.t.job.saveSuccess);
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
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('isSelected', isSelected));
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('isBookmarkProcessing', isBookmarkProcessing));
    properties.add(IntProperty('jobId', jobId));
  }
}

class _ApplyNavBar extends StatelessWidget {
  const _ApplyNavBar({required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(jobDetailControllerProvider);
            return switch (state) {
              JobDetailLoading() => const JobDetailNavBarShimmer(),
              JobDetailError() => const SizedBox.shrink(),
              JobDetailInitial() => const SizedBox.shrink(),
              JobDetailLoaded() => ElevatedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useSafeArea: true,
                    builder:
                        (context) => Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: _ApplyModal(jobId: jobId),
                        ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
                child: Text(
                  context.t.common.apply,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            };
          },
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

class _ApplyModal extends HookWidget {
  const _ApplyModal({required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context) {
    final file = useState<FileSelectorResult?>(null);
    final controller = useTextEditingController();
    final text = useState<String>(context.t.job.uploadNewCV);
    return SafeArea(
      child: Container(
        height: 560.0,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.0,
            children: [
              Text(
                context.t.job.attachCV,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        text.value,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final result = await ref.read(fileServiceProvider).uploadFile([
                        const FileSelector(label: 'CV', extensions: ['pdf']),
                      ]);
                      result.fold(
                        ifLeft: (_) => null,
                        ifRight: (e) {
                          if (e.data.length > 512 * 1024) {
                            NotificationService.error(context: context, message: context.t.validation.file.cvFormat);
                            return;
                          }
                          text.value = e.name;
                          file.value = e;
                        },
                      );
                    },
                  );
                },
              ),
              if (file.value != null) PreviewButton(file: file),
              Text(
                context.t.common.resumeLetter.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: controller,
                minLines: 5,
                maxLines: 5,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                  hintText: context.t.common.resumeLetter.description,
                  hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox.shrink(),
              _ApplyButton(jobId: jobId, file: file, controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.jobId, required this.file, required this.controller});

  final int jobId;

  final ValueNotifier<FileSelectorResult?> file;

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return CustomButton(
          onPressed: () async {
            if (file.value == null) {
              NotificationService.error(context: context, message: context.t.validation.required.cv);
              return;
            }
            if (controller.text.trim().isEmpty) {
              NotificationService.error(context: context, message: context.t.job.noReferenceLetter);
              return;
            }
            await ref
                .read(applyJobControllerProvider.notifier)
                .applyJob(jobId: jobId, referenceLetter: controller.text, cv: file.value!);
            final state = ref.read(applyJobControllerProvider);
            if (state is ApplyJobError) {
              if (context.mounted) {
                NotificationService.error(context: context, message: context.t.job.appliedJob);
              }
            } else if (state is ApplyJobLoaded) {
              if (context.mounted) {
                NotificationService.success(context: context, message: context.t.job.applicationSuccess);
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
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
    properties.add(DiagnosticsProperty<ValueNotifier<FileSelectorResult?>>('file', file));
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
  }
}

class JobDetailShimmerCard extends StatelessWidget {
  const JobDetailShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Company Logo
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              alignment: Alignment.center,
              width: 86.0,
              height: 86.0,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[400]!, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Job Title
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 200,
              height: 24.0,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
            ),
          ),
          const SizedBox(height: 12.0),

          // Company Name
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 150,
              height: 18.0,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
            ),
          ),
          const SizedBox(height: 12.0),

          // Location
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4.0),
                Container(
                  width: 120,
                  height: 16.0,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Job Categories/Majors
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(5),
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Job Display Cards (Salary, Exp, etc.)
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) => _buildShimmerJobDisplayItem()),
            ),
          ),
          const SizedBox(height: 24.0),

          // Tab Indicators
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Content Area
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    width: double.infinity,
                    height: 16.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerJobDisplayItem() {
    return Column(
      children: [
        Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const SizedBox(height: 8.0),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
        ),
        const SizedBox(height: 4.0),
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
        ),
      ],
    );
  }
}

class JobDetailNavBarShimmer extends StatelessWidget {
  const JobDetailNavBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: double.infinity,
            height: 56.0,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
      ),
    );
  }
}
