import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../injection_container.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import 'applied_jobs_page.dart';
import 'saved_jobs_page.dart';

/// The main home page of the application, acting as a container for different
/// sections accessible via a bottom navigation bar.
///
/// It manages a [PageView] to display different pages like job listings,
/// applied jobs, saved jobs, and user profile.
class HomePage extends HookConsumerWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  /// The list of pages managed by the [PageView] and [BottomNavBar].
  static const List<Widget> _pages = [
    _JobPage(),
    AppliedJobsPage(),
    SavedJobsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.read(authControllerProvider);
      if (authState is AuthInitial) {
        // ignore: lines_longer_than_80_chars
        final userId = await InjectionContainer.get<IAuthStorageService>().getUserId();
        // ignore: lines_longer_than_80_chars
        await ref.read(authControllerProvider.notifier).getCandidateData(userId!);
      }
    });
    final controller = usePageController();
    final index = useState(0);
    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      body: PageView.builder(
        controller: controller,
        itemCount: _pages.length,
        itemBuilder: (final context, final index) => _pages[index],
      ),
      bottomNavigationBar: BottomNavBar(
        index: index.value,
        onTap: (final int value) async {
          controller.jumpToPage(value);
          index.value = value;
        },
      ),
    );
  }
}

/// The primary page for browsing and searching for jobs.
///
/// It includes a search bar, filter options, and an infinitely scrolling list
/// of job cards. It handles job searching, filtering, and pagination.
class _JobPage extends HookConsumerWidget {
  /// Creates a [_JobPage].
  const _JobPage();

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final controller = useTextEditingController(
      text: ref.read(jobFilterControllerProvider).title,
    );
    final node = useFocusNode();
    final isLoading = useState(false);
    final page = useState(0);
    final debounceTimer = useRef<Timer?>(null);
    final performSearch = useCallback((final String searchText) {
      page.value = 0;
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(const Duration(milliseconds: 800), () async {
        final jobFilterState = ref.read(jobFilterControllerProvider);
        await ref.read(searchJobsControllerProvider.notifier).reset();
        if (jobFilterState is! JobFilterOnSearch) {
          await ref
              .read(jobFilterControllerProvider.notifier)
              .saveFilteredJob(
                title: searchText,
                schedules: jobFilterState.schedules,
                positions: jobFilterState.positions,
                majors: jobFilterState.majors,
                city: null,
                schedulesList: [],
                positionsList: [],
                majorsList: [],
              );
          return;
        }
        await ref
            .read(jobFilterControllerProvider.notifier)
            .saveFilteredJob(
              title: searchText,
              schedules: jobFilterState.schedules,
              positions: jobFilterState.positions,
              majors: jobFilterState.majors,
              city: jobFilterState.city,
              schedulesList: jobFilterState.schedulesList,
              positionsList: jobFilterState.positionsList,
              majorsList: jobFilterState.majorsList,
            );
        final controller = ref.read(searchJobsControllerProvider.notifier);
        // ignore: lines_longer_than_80_chars
        if (searchText.isEmpty && ref.read(jobFilterControllerProvider.notifier).isEmpty()) {
          await controller.searchJobs(page: 0, limit: 10);
        } else {
          // ignore: lines_longer_than_80_chars
          final currentFilterState = ref.read(jobFilterControllerProvider) as JobFilterOnSearch;
          await controller.filterJobs(
            page: 0,
            limit: 10,
            city: currentFilterState.city,
            title: currentFilterState.title,
            schedules: currentFilterState.schedulesList,
            positions: currentFilterState.positionsList,
            majors: currentFilterState.majorsList,
          );
        }
      });
    }, [ref, page]);
    useEffect(() {
      controller.addListener(() {
        performSearch(controller.text);
      });

      return () {
        debounceTimer.value?.cancel();
        controller.removeListener(() {});
      };
    }, [controller, performSearch]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(searchJobsControllerProvider);
      if (state is SearchJobsInitial) {
        await ref
            .read(searchJobsControllerProvider.notifier)
            .searchJobs(
              page: page.value,
              limit: 10,
            );
        page.value++;
        // ignore: lines_longer_than_80_chars
        final scheduleController = ref.read(scheduleControllerProvider.notifier);
        // ignore: lines_longer_than_80_chars
        final positionController = ref.read(positionControllerProvider.notifier);
        final majorController = ref.read(majorControllerProvider.notifier);
        await scheduleController.getSchedules();
        await positionController.getPositions();
        await majorController.getMajors();
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/images/icon.png', width: 118, height: 50),
                  ),
                  const _LanguageSelector(),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: SearchBar(
                      leading: Icon(
                        IconlyLight.search,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      hintText: context.t.common.searchJob,
                      focusNode: node,
                      controller: controller,
                      hintStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          // ignore: lines_longer_than_80_chars
                          color: Theme.of(context).colorScheme.onSecondary.withValues(
                            alpha: 0.48,
                          ),
                        ),
                      ),
                      textStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          // ignore: lines_longer_than_80_chars
                          color: Theme.of(context).colorScheme.onSecondary.withValues(
                            alpha: 0.96,
                          ),
                        ),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            // ignore: lines_longer_than_80_chars
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                      ),
                      elevation: const WidgetStatePropertyAll(1),
                    ),
                  ),
                  _CustomFilter(
                    controller: controller,
                    isLoading: isLoading,
                    ref: ref,
                    node: node,
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            Consumer(
              builder: (final context, final ref, final child) {
                final jobState = ref.watch(searchJobsControllerProvider);
                switch (jobState) {
                  case SearchJobsInitial():
                  case SearchJobsLoading():
                    return SliverToBoxAdapter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        // ignore: lines_longer_than_80_chars
                        itemBuilder: (final context, final index) => const ShimmerCard(),
                      ),
                    );
                  case SearchJobsError():
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          jobState.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  case SearchJobsLoaded():
                    if (jobState.jobs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            context.t.job.noJobFound,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }
                    final state = PagingState<int, Job>(
                      pages: [jobState.jobs],
                      keys: const [0],
                      hasNextPage: jobState.finished,
                    );
                    return _CustomPagedList(page: page, ref: ref, state: state);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom filter button widget used on the [_JobPage].
///
/// When pressed, it fetches necessary filter data (cities, job types, etc.)
/// and displays a [_FilterModal] bottom sheet.
class _CustomFilter extends StatelessWidget {
  /// Creates a [_CustomFilter] widget.
  ///
  /// [isLoading] A [ValueNotifier] to indicate if filter data is being loaded.
  /// [ref] The [WidgetRef] for accessing Riverpod providers.
  /// [controller] The [TextEditingController] for the search bar.
  /// [node] The [FocusNode] for the search bar.
  const _CustomFilter({
    required this.isLoading,
    required this.ref,
    required this.controller,
    required this.node,
  });

  /// Notifier to track the loading state when fetching filter options.
  final ValueNotifier<bool> isLoading;

  /// Riverpod widget reference for accessing providers.
  final WidgetRef ref;

  /// Controller for the search text input, used to preserve search term
  /// when applying filters.
  final TextEditingController controller;

  /// Focus node for the search text input.
  final FocusNode node;

  @override
  Widget build(final BuildContext context) => FloatingActionButton(
    backgroundColor: Theme.of(context).colorScheme.onPrimary,
    tooltip: context.t.common.filter,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      side: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
    ),
    elevation: 2,
    onPressed: () async {
      if (isLoading.value) {
        return;
      }
      isLoading.value = true;
      try {
        final citiesController = ref.read(citiesControllerProvider.notifier);
        // ignore: lines_longer_than_80_chars
        final scheduleController = ref.read(scheduleControllerProvider.notifier);
        // ignore: lines_longer_than_80_chars
        final positionController = ref.read(positionControllerProvider.notifier);
        final majorController = ref.read(majorControllerProvider.notifier);
        await Future.wait([
          citiesController.fetchCities(),
          scheduleController.getSchedules(),
          positionController.getPositions(),
          majorController.getMajors(),
        ]);
        final jobFilterState = ref.read(jobFilterControllerProvider);
        if (context.mounted) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder:
                (final context) => _FilterModal(
                  jobTypes: jobFilterState.schedules,
                  jobPositions: jobFilterState.positions,
                  jobMajors: jobFilterState.majors,
                  jobCity: jobFilterState.city,
                  searchController: controller,
                  searchNode: node,
                ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    },
    child: Icon(
      IconlyLight.filter,
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ValueNotifier<bool>>('isLoading', isLoading))
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(
        DiagnosticsProperty<TextEditingController>('controller', controller),
      )
      ..add(DiagnosticsProperty<FocusNode>('node', node));
  }
}

/// A custom paged list widget for displaying jobs with infinite scrolling.
///
/// It uses [PagedSliverList] to handle pagination and fetching more jobs
/// as the user scrolls.
class _CustomPagedList extends StatelessWidget {
  /// Creates a [_CustomPagedList].
  ///
  /// [state] The [PagingState] containing the current list of jobs and
  /// pagination status.
  /// [ref] The [WidgetRef] for accessing Riverpod providers.
  /// [page] A [ValueNotifier] tracking the current page number for fetching.
  const _CustomPagedList({
    required this.state,
    required this.ref,
    required this.page,
  });

  /// The current paging state, including loaded items and next page key.
  final PagingState<int, Job> state;

  /// Riverpod widget reference for accessing providers.
  final WidgetRef ref;

  /// Notifier for the current page number, used for fetching subsequent pages.
  final ValueNotifier<int> page;

  @override
  Widget build(final BuildContext context) => PagedSliverList<int, Job>(
    state: state,
    fetchNextPage: () async {
      if (!context.mounted) {
        return;
      }
      final controller = ref.read(searchJobsControllerProvider.notifier);
      if (ref.read(jobFilterControllerProvider.notifier).isEmpty()) {
        await controller.searchJobs(page: page.value, limit: 10);
      } else {
        // ignore: lines_longer_than_80_chars
        final jobFilterState = ref.read(jobFilterControllerProvider) as JobFilterOnSearch;
        await controller.filterJobs(
          page: page.value,
          limit: 10,
          city: jobFilterState.city,
          title: jobFilterState.title,
          schedules: jobFilterState.schedulesList,
          positions: jobFilterState.positionsList,
          majors: jobFilterState.majorsList,
        );
      }
      page.value++;
    },
    builderDelegate: PagedChildBuilderDelegate<Job>(
      itemBuilder:
          (final context, final item, final index) => JobCard(
            job: item,
            onPressed: () async {
              // ignore: lines_longer_than_80_chars
              final jobDetailState = ref.read(jobDetailControllerProvider.notifier);
              await jobDetailState.getJobDetail(jobId: item.id);
              if (context.mounted) {
                await JobDetailRoute(id: item.id).push(context);
              }
            },
          ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<PagingState<int, Job>>('state', state))
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(DiagnosticsProperty<ValueNotifier<int>>('page', page));
  }
}

/// A modal bottom sheet widget for applying job filters.
///
/// It allows users to select job location, type, position, and major.
class _FilterModal extends HookWidget {
  /// Creates a [_FilterModal].
  ///
  /// [searchController] The controller for the main search bar on [_JobPage].
  /// [searchNode] The focus node for the main search bar.
  /// [jobTypes] The currently selected set of job type IDs.
  /// [jobPositions] The currently selected set of job position IDs.
  /// [jobMajors] The currently selected set of job major IDs.
  /// [jobCity] The currently selected city for filtering.
  const _FilterModal({
    required this.searchController,
    required this.searchNode,
    required this.jobTypes,
    required this.jobPositions,
    required this.jobMajors,
    this.jobCity,
  });

  /// Controller for the search input field on the main job page.
  final TextEditingController searchController;

  /// Focus node for the search input field on the main job page.
  final FocusNode searchNode;

  /// Set of selected job type IDs.
  final Set<int> jobTypes;

  /// Set of selected job position IDs.
  final Set<int> jobPositions;

  /// Set of selected job major IDs.
  final Set<int> jobMajors;

  /// The currently selected city for filtering.
  final City? jobCity;

  @override
  Widget build(final BuildContext context) {
    final jobTypeSelection = useState<Set<int>>(jobTypes);
    final jobPositionSelection = useState<Set<int>>(jobPositions);
    final majorSelection = useState<Set<int>>(jobMajors);
    final citySelection = useState<City?>(jobCity);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconlyLight.location,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                context.t.auth.location,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (final context, final ref, final child) {
              final state = ref.watch(citiesControllerProvider);
              return switch (state) {
                CitiesInitial() => const Center(child: SizedBox.shrink()),
                CitiesLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                CitiesError() => Center(
                  child: Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                // ignore: lines_longer_than_80_chars
                CitiesLoaded(cities: final cities) => DropdownButtonField<City?>(
                  value: citySelection.value,
                  items: [
                    // ignore: lines_longer_than_80_chars
                    DropdownMenuItem<City?>(child: Text('-${context.t.common.chooseALocation}-')),
                    ...cities.map(
                      (final City value) => DropdownMenuItem<City?>(
                        value: value,
                        child: Text(value.name),
                      ),
                    ),
                  ],
                  label: '-${context.t.common.chooseALocation}-',
                  textBuilder: () {
                    if (citySelection.value != null) {
                      return citySelection.value!.name;
                    }
                    return '-${context.t.common.chooseALocation}-';
                  },
                  onChanged: (final City? value) async {
                    citySelection.value = value;
                  },
                ),
              };
            },
          ),
          const SizedBox(height: 24),
          Text(
            context.t.job.type,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (final context, final ref, final child) {
              final state = ref.watch(scheduleControllerProvider);
              return switch (state) {
                ScheduleInitial() => const Center(child: SizedBox.shrink()),
                ScheduleLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ScheduleError() => Center(
                  child: Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ScheduleLoaded(schedules: final schedules) => SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder:
                        (_, final index) => _SelectedOption(
                          label: schedules[index].name,
                          index: index,
                          selection: jobTypeSelection,
                        ),
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemCount: schedules.length,
                  ),
                ),
              };
            },
          ),
          const SizedBox(height: 24),
          Text(
            context.t.job.jobPosition,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (final context, final ref, final child) {
              final state = ref.watch(positionControllerProvider);
              return switch (state) {
                PositionInitial() => const Center(child: SizedBox.shrink()),
                PositionLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                PositionError() => Center(
                  child: Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                PositionLoaded(positions: final positions) => SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder:
                        (_, final index) => _SelectedOption(
                          label: positions[index].name,
                          index: index,
                          selection: jobPositionSelection,
                        ),
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemCount: positions.length,
                  ),
                ),
              };
            },
          ),
          const SizedBox(height: 24),
          Text(
            context.t.job.major,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (final context, final ref, final child) {
              final state = ref.watch(majorControllerProvider);
              return switch (state) {
                MajorInitial() => const Center(child: SizedBox.shrink()),
                MajorLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                MajorError() => Center(
                  child: Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                MajorLoaded(majors: final majors) => SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder:
                        (_, final index) => _SelectedOption(
                          label: majors[index].name,
                          index: index,
                          selection: majorSelection,
                        ),
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemCount: majors.length,
                  ),
                ),
              };
            },
          ),
          const SizedBox(height: 50),
          Consumer(
            builder:
                (final context, final ref, final child) => _FilterButton(
                  ref: ref,
                  searchController: searchController,
                  searchNode: searchNode,
                  jobTypeSelection: jobTypeSelection,
                  jobPositionSelection: jobPositionSelection,
                  majorSelection: majorSelection,
                  citySelection: citySelection,
                ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<City?>('jobCity', jobCity))
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'searchController',
          searchController,
        ),
      )
      ..add(DiagnosticsProperty<FocusNode>('searchNode', searchNode))
      ..add(IterableProperty<int>('jobTypes', jobTypes))
      ..add(IterableProperty<int>('jobPositions', jobPositions))
      ..add(IterableProperty<int>('jobMajors', jobMajors));
  }
}

/// The "Apply Filter" button within the [_FilterModal].
///
/// This button takes the selected filter options from the modal,
/// saves them using [jobFilterControllerProvider], and then closes the modal.
/// It also unfocuses the search bar if it was focused.
class _FilterButton extends StatelessWidget {
  /// Creates a [_FilterButton].
  const _FilterButton({
    super.key,
    required this.ref,
    required this.searchController,
    required this.searchNode,
    required this.jobTypeSelection,
    required this.jobPositionSelection,
    required this.majorSelection,
    required this.citySelection,
  });

  /// Riverpod widget reference for accessing providers.
  final WidgetRef ref;

  /// Controller for the search input field on the main job page.
  final TextEditingController searchController;

  /// Focus node for the search input field on the main job page.
  final FocusNode searchNode;

  /// Notifier holding the set of selected job type indices from the modal.
  final ValueNotifier<Set<int>> jobTypeSelection;

  /// Notifier holding the set of selected job position indices from the modal.
  final ValueNotifier<Set<int>> jobPositionSelection;

  /// Notifier holding the set of selected major indices from the modal.
  final ValueNotifier<Set<int>> majorSelection;

  /// Notifier holding the selected city from the modal.
  final ValueNotifier<City?> citySelection;

  @override
  Widget build(final BuildContext context) => CustomButton(
    onPressed: () async {
      final majorState = ref.read(majorControllerProvider);
      final positionState = ref.read(positionControllerProvider);
      final scheduleState = ref.read(scheduleControllerProvider);
      final List<Major>? major =
          // ignore: lines_longer_than_80_chars
          majorState is MajorLoaded ? majorSelection.value.map((final e) => majorState.majors[e]).toList() : null;
      final List<Position>? position =
          positionState is PositionLoaded
              // ignore: lines_longer_than_80_chars
              ? [...jobPositionSelection.value.map((final e) => positionState.positions[e])]
              : null;
      final List<Schedule>? schedule =
          scheduleState is ScheduleLoaded
              // ignore: lines_longer_than_80_chars
              ? jobTypeSelection.value.map((final e) => scheduleState.schedules[e]).toList()
              : null;
      Navigator.of(context).pop();
      await ref
          .read(jobFilterControllerProvider.notifier)
          .saveFilteredJob(
            schedules: jobTypeSelection.value,
            positions: jobPositionSelection.value,
            majors: majorSelection.value,
            title: searchController.text,
            city: citySelection.value,
            schedulesList: schedule,
            positionsList: position,
            majorsList: major,
          );
      if (searchNode.hasFocus) {
        searchNode.unfocus();
      }
    },
    child: Center(child: Text(context.t.common.applyFilter)),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'searchController',
          searchController,
        ),
      )
      ..add(DiagnosticsProperty<FocusNode>('searchNode', searchNode))
      ..add(
        DiagnosticsProperty<ValueNotifier<Set<int>>>(
          'jobTypeSelection',
          jobTypeSelection,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<Set<int>>>(
          'jobPositionSelection',
          jobPositionSelection,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<Set<int>>>(
          'majorSelection',
          majorSelection,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<City?>>(
          'citySelection',
          citySelection,
        ),
      );
  }
}

/// A widget representing a selectable option (e.g., for job type, position).
///
/// It's a [FilledButton] that toggles its selection state when pressed.
class _SelectedOption extends StatelessWidget {
  /// Creates a [_SelectedOption].
  ///
  /// [label] The text to display on the button.
  /// [index] The index of this option within its list, used for selection state
  /// [selection] A [ValueNotifier] holding the set of selected indices.
  const _SelectedOption({
    required this.label,
    required this.index,
    required this.selection,
  });

  /// The text label displayed on the option button.
  final String label;

  /// The index of this option, used to manage its selection state.
  final int index;

  /// Notifier holding the set of currently selected option indices.
  final ValueNotifier<Set<int>> selection;

  @override
  Widget build(final BuildContext context) {
    final isSelected = selection.value.contains(index);
    return FilledButton(
      onPressed: () async {
        if (isSelected) {
          // ignore: lines_longer_than_80_chars
          selection.value = selection.value.where((final e) => e != index).toSet();
        } else {
          selection.value = {...selection.value, index};
        }
      },
      style: FilledButton.styleFrom(
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        // ignore: lines_longer_than_80_chars
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(IntProperty('index', index))
      ..add(
        DiagnosticsProperty<ValueNotifier<Set<int>>>('selection', selection),
      );
  }
}

/// A widget for selecting the application language (Vietnamese or English).
///
/// It uses a [MenuAnchor] to display language options when an icon
/// (representing the current language) is tapped.
class _LanguageSelector extends HookWidget {
  /// Creates a [_LanguageSelector].
  const _LanguageSelector();

  @override
  Widget build(final BuildContext context) {
    final isVietnamese = useState(LocaleSettings.currentLocale == AppLocale.vi);
    return MenuAnchor(
      style: MenuStyle(elevation: WidgetStateProperty.all(4)),
      crossAxisUnconstrained: false,
      alignmentOffset: const Offset(0, 8),
      builder:
          (
            final BuildContext context,
            final MenuController controller,
            final Widget? child,
          ) => IconButton(
            iconSize: 50,
            onPressed: () async {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: CircleAvatar(
              backgroundImage:
                  isVietnamese.value
                      ? const AssetImage('assets/images/vn.png')
                      : const AssetImage('assets/images/en.png'),
            ),
          ),
      menuChildren: [
        MenuItemButton(
          child: Row(
            spacing: 8,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircleAvatar(backgroundImage: AssetImage('assets/images/vn.png')),
              ),
              Text('Vietnamese', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          onPressed: () async {
            await LocaleSettings.setLocale(AppLocale.vi);
            final localeService = InjectionContainer.get<LocaleService>();
            await localeService.saveLocale(AppLocale.vi);
            isVietnamese.value = true;
          },
        ),
        MenuItemButton(
          child: Row(
            spacing: 8,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircleAvatar(backgroundImage: AssetImage('assets/images/en.png')),
              ),
              Text('English', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          onPressed: () async {
            await LocaleSettings.setLocale(AppLocale.en);
            final localeService = InjectionContainer.get<LocaleService>();
            await localeService.saveLocale(AppLocale.en);
            isVietnamese.value = false;
          },
        ),
      ],
    );
  }
}
