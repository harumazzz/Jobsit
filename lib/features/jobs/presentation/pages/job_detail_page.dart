import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:elegant_notification/elegant_notification.dart';
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
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

class JobDetailPage extends HookConsumerWidget {
  const JobDetailPage({super.key, required this.jobId});

  final int jobId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final isSelected = useState(ref.read(savedJobControllerProvider.notifier).contains(jobId));
    final selectedTabIndex = useState(0);
    final isBookmarkProcessing = useState(false);

    return Scaffold(
      backgroundColor: const Color(0xFff5fafd),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 38.0,
            floating: true,
            backgroundColor: const Color(0xFff5fafd),
            flexibleSpace: const FlexibleSpaceBar(title: Text('Job Detail'), centerTitle: true),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(jobDetailControllerProvider);
                  return switch (state) {
                    JobDetailLoading() => const Center(child: CircularProgressIndicator()),
                    JobDetailError() => const SizedBox.shrink(),
                    JobDetailInitial() => const SizedBox.shrink(),
                    JobDetailLoaded(job: final job) => IconButton(
                      icon: Icon(isSelected.value ? IconlyBold.bookmark : IconlyLight.bookmark),
                      tooltip: 'Bookmark',
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
                              ElegantNotification.success(
                                background: const Color(0xFFDEF2ED),
                                description: const Text('Job has been removed successfully!'),
                              ).show(context);
                            }
                          } else {
                            await ref.read(savedJobControllerProvider.notifier).addJob(job: job);
                            if (context.mounted) {
                              ElegantNotification.success(
                                background: const Color(0xFFDEF2ED),
                                description: const Text('Job has been saved successfully!'),
                              ).show(context);
                            }
                          }
                        } finally {
                          isBookmarkProcessing.value = false;
                        }
                      },
                    ),
                  };
                },
              ),
            ],
          ),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(jobDetailControllerProvider);
              return switch (state) {
                JobDetailLoading() => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                JobDetailError(message: final message) => SliverFillRemaining(
                  child: Center(child: Text('Error: $message')),
                ),
                JobDetailInitial() => const SliverFillRemaining(child: Center(child: Text('No data available'))),
                JobDetailLoaded(job: final job, relatedJobs: final relatedJobs) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16.0),
                        job.company.logo != null
                            ? Container(
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
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) {
                                  return Icon(
                                    IconlyLight.image,
                                    size: 48.0,
                                    color: Theme.of(context).colorScheme.primary,
                                  );
                                },
                              ),
                            )
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
                          job.company.name ?? 'Company Name',
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
                              job.company.location ?? 'Location',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            JobIntroduce(
                              title: 'Position',
                              content: job.positions.isNotEmpty ? job.positions[0].name : 'Not specified',
                              child: Icon(
                                IconlyLight.profile,
                                size: 24.0,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            JobIntroduce(
                              title: 'Type',
                              content: job.schedules.isNotEmpty ? job.schedules[0].name : ' Not specified',
                              child: Icon(IconlyLight.work, size: 24.0, color: Theme.of(context).colorScheme.primary),
                            ),
                            JobIntroduce(
                              title: 'Salary',
                              content: '\$${job.minInUSD} - \$${job.maxInUSD}',
                              child: Icon(IconlyLight.wallet, size: 24.0, color: Theme.of(context).colorScheme.primary),
                            ),
                            JobIntroduce(
                              title: 'Deadline',
                              content: DateFormat('dd/MM/yy').format(job.applicationDeadline.toLocal()),
                              child: Icon(
                                IconlyLight.calendar,
                                size: 24.0,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  selectedTabIndex.value = 0;
                                  pageController.jumpToPage(0);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: selectedTabIndex.value == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                    ),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                      fontWeight: selectedTabIndex.value == 0 ? FontWeight.bold : FontWeight.normal,
                                      color:
                                          selectedTabIndex.value == 0
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
                                  selectedTabIndex.value = 1;
                                  pageController.jumpToPage(1);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: selectedTabIndex.value == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                    ),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Company',
                                    style: TextStyle(
                                      fontWeight: selectedTabIndex.value == 1 ? FontWeight.bold : FontWeight.normal,
                                      color:
                                          selectedTabIndex.value == 1
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Job Description',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    job.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Company Overview',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Flexible(
                                    child: Text(
                                      job.company.description ?? 'No company details available',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    'Company Address',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    children: [
                                      Icon(
                                        IconlyLight.location,
                                        size: 24.0,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        job.company.location ?? 'Location',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    'Other Jobs',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16.0),
                                  relatedJobs.isEmpty
                                      ? SizedBox(
                                        height: 200.0,
                                        child: Center(
                                          child: Text(
                                            'No other jobs available.',
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              color: Theme.of(context).colorScheme.onSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                      : CarouselSlider(
                                        options: CarouselOptions(height: 200.0, autoPlay: true),
                                        items: [
                                          ...relatedJobs.map((e) {
                                            return JobCard(
                                              job: e,
                                              onPressed: () async {
                                                final jobDetailState = ref.read(jobDetailControllerProvider.notifier);
                                                await jobDetailState.getJobDetail(jobId: e.id);
                                                if (context.mounted) {
                                                  JobDetailRoute(id: e.id).pushReplacement(context);
                                                }
                                              },
                                            );
                                          }),
                                        ],
                                      ),
                                ],
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

class _ApplyNavBar extends StatelessWidget {
  const _ApplyNavBar({required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 13), blurRadius: 5.0, offset: const Offset(0, -1))],
      ),
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
                  builder: (context) => _ApplyModal(jobId: jobId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ),
              child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          };
        },
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
    final text = useState<String>('Upload new CV');
    return Container(
      height: 560.0,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.0,
        children: [
          Text(
            'Attached CV',
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
                      ElegantNotification.error(
                        background: const Color(0xFFFCE8DB),
                        description: Text(error.message),
                      ).show(context);
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
                          content: SizedBox(height: 600.0, width: 400.0, child: PdfViewerPage(data: file.value!.data)),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                        ),
                  );
                },
                child: Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          Text(
            'Resume letter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
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
              hintText: 'Write a brief introduce about yourself',
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
                    ElegantNotification.error(
                      background: const Color(0xFFFCE8DB),
                      description: const Text('Please write a reference letter'),
                    ).show(context);
                    return;
                  }
                  await ref
                      .read(applyJobControllerProvider.notifier)
                      .applyJob(jobId: jobId, referenceLetter: controller.text, cv: file.value!);
                  final state = ref.read(applyJobControllerProvider);
                  if (state is ApplyJobError) {
                    if (context.mounted) {
                      ElegantNotification.error(
                        background: const Color(0xFFFCE8DB),
                        description: Text(state.message),
                      ).show(context);
                    }
                  } else if (state is ApplyJobLoaded) {
                    if (context.mounted) {
                      ElegantNotification.success(
                        background: const Color(0xFFDEF2ED),
                        description: const Text('Job has been applied successfully!'),
                      ).show(context);
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
