import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdfx/pdfx.dart';
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
                JobDetailLoading() => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
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
                                  final jobDetailState = ref.read(jobDetailControllerProvider.notifier);
                                  await jobDetailState.getJobDetail(jobId: job.id);
                                  if (context.mounted) {
                                    JobDetailRoute(id: job.id).pushReplacement(context);
                                  }
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
          JobDetailLoading() => const Center(child: CircularProgressIndicator()),
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
                await Future.delayed(const Duration(milliseconds: 100));
                isSelected.value = !isSelected.value;
                if (ref.read(savedJobControllerProvider.notifier).contains(state.job.id)) {
                  await ref.read(savedJobControllerProvider.notifier).removeJob(jobId: jobId);
                  if (context.mounted) {
                    NotificationService.error(context: context, message: context.t.job.unsaveSuccess);
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
              JobDetailLoading() => const Center(child: CircularProgressIndicator()),
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
                        ifLeft: (error) {
                          NotificationService.error(context: context, message: error.message);
                        },
                        ifRight: (e) {
                          text.value = e.name;
                          file.value = e;
                        },
                      );
                    },
                  );
                },
              ),
              if (file.value != null)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 0.84,
                  child: CustomButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(file.value!.name),
                              content: SizedBox(
                                height: 600.0,
                                width: 400.0,
                                child: PdfViewerPage(data: file.value!.data),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(context.t.common.close),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Text(
                      context.t.common.preview,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
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
              Consumer(
                builder: (context, ref, child) {
                  return CustomButton(
                    onPressed: () async {
                      if (file.value == null) {
                        return;
                      }
                      if (controller.text.trim().isEmpty) {
                        NotificationService.error(context: context, message: context.t.validation.file.cvFormat);
                        return;
                      }
                      await ref
                          .read(applyJobControllerProvider.notifier)
                          .applyJob(jobId: jobId, referenceLetter: controller.text, cv: file.value!);
                      final state = ref.read(applyJobControllerProvider);
                      if (state is ApplyJobError) {
                        if (context.mounted) {
                          NotificationService.error(context: context, message: state.message);
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
                        'Submit',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                },
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
    properties.add(IntProperty('jobId', jobId));
  }
}

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key, required this.data});

  final Uint8List data;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Uint8List>('data', [data]));
  }
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(document: PdfDocument.openData(widget.data));
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [PdfView(controller: _pdfController, scrollDirection: Axis.vertical)]);
  }
}
