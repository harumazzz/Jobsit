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

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  static const List<Widget> _pages = [_JobPage(), AppliedJobsPage(), SavedJobsPage(), ProfilePage()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.read(authControllerProvider);
      if (authState is AuthInitial) {
        final userId = await InjectionContainer.get<IAuthStorageService>().getUserId();
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
        itemBuilder: (context, index) {
          return _pages[index];
        },
      ),
      bottomNavigationBar: BottomNavBar(
        index: index.value,
        onTap: (int value) async {
          controller.jumpToPage(value);
          index.value = value;
        },
      ),
    );
  }
}

class _JobPage extends HookConsumerWidget {
  const _JobPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: ref.read(jobFilterControllerProvider).title);
    final node = useFocusNode();
    final isLoading = useState(false);
    final page = useState(0);
    final debounceTimer = useRef<Timer?>(null);
    final performSearch = useCallback(
      (String searchText) {
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
          final searchController = ref.read(searchJobsControllerProvider.notifier);
          if (searchText.isEmpty && ref.read(jobFilterControllerProvider.notifier).isEmpty) {
            await searchController.searchJobs(page: 0, limit: 10);
          } else {
            final currentFilterState = ref.read(jobFilterControllerProvider) as JobFilterOnSearch;
            await searchController.filterJobs(
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
      },
      () {
        return [ref, page];
      }(),
    );
    useEffect(
      () {
        controller.addListener(() {
          performSearch(controller.text);
        });

        return () {
          debounceTimer.value?.cancel();
          controller.removeListener(() {});
        };
      },
      () {
        return [controller, performSearch];
      }(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(searchJobsControllerProvider);
      if (state is SearchJobsInitial) {
        await ref.read(searchJobsControllerProvider.notifier).searchJobs(page: page.value, limit: 10);
        page.value++;
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset('assets/images/icon.png', width: 118.0, height: 50.0),
                  ),
                  const _LanguageSelector(),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            SliverToBoxAdapter(
              child: Row(
                spacing: 8.0,
                children: [
                  Expanded(
                    child: SearchBar(
                      leading: Icon(IconlyLight.search, color: Theme.of(context).colorScheme.primaryContainer),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      hintText: context.t.common.searchJob,
                      focusNode: node,
                      controller: controller,
                      hintStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.48),
                        ),
                      ),
                      textStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.96),
                        ),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
                        ),
                      ),
                      elevation: const WidgetStatePropertyAll(1.0),
                    ),
                  ),
                  _CustomFilter(controller: controller, isLoading: isLoading, ref: ref, node: node),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            Consumer(
              builder: (context, ref, child) {
                final jobState = ref.watch(searchJobsControllerProvider);
                switch (jobState) {
                  case SearchJobsInitial():
                  case SearchJobsLoading():
                    return SliverToBoxAdapter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (context, index) => const ShimmerCard(),
                      ),
                    );
                  case SearchJobsError():
                    return SliverToBoxAdapter(
                      child: Center(child: Text(jobState.message, style: Theme.of(context).textTheme.bodyLarge)),
                    );
                  case SearchJobsLoaded():
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

class _CustomFilter extends StatelessWidget {
  const _CustomFilter({required this.isLoading, required this.ref, required this.controller, required this.node});

  final ValueNotifier<bool> isLoading;

  final WidgetRef ref;

  final TextEditingController controller;

  final FocusNode node;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      tooltip: context.t.common.filter,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        side: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      elevation: 2.0,
      onPressed: () async {
        if (isLoading.value) {
          return;
        }
        isLoading.value = true;
        try {
          final citiesController = ref.read(citiesControllerProvider.notifier);
          final scheduleController = ref.read(scheduleControllerProvider.notifier);
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
              builder: (context) {
                return _FilterModal(
                  jobTypes: jobFilterState.schedules,
                  jobPositions: jobFilterState.positions,
                  jobMajors: jobFilterState.majors,
                  jobCity: jobFilterState.city,
                  searchController: controller,
                  searchNode: node,
                );
              },
            );
          }
        } finally {
          isLoading.value = false;
        }
      },
      child: Icon(IconlyLight.filter, color: Theme.of(context).colorScheme.primaryContainer),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('isLoading', isLoading));
    properties.add(DiagnosticsProperty<WidgetRef>('ref', ref));
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(DiagnosticsProperty<FocusNode>('node', node));
  }
}

class _CustomPagedList extends StatelessWidget {
  const _CustomPagedList({required this.state, required this.ref, required this.page});

  final PagingState<int, Job> state;

  final WidgetRef ref;

  final ValueNotifier<int> page;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, Job>(
      state: state,
      fetchNextPage: () async {
        if (!context.mounted) {
          return;
        }
        final controller = ref.read(searchJobsControllerProvider.notifier);
        if (ref.read(jobFilterControllerProvider.notifier).isEmpty) {
          await controller.searchJobs(page: page.value, limit: 10);
        } else {
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
        itemBuilder: (context, item, index) {
          return JobCard(
            job: item,
            onPressed: () async {
              final jobDetailState = ref.read(jobDetailControllerProvider.notifier);
              await jobDetailState.getJobDetail(jobId: item.id);
              if (context.mounted) {
                await JobDetailRoute(id: item.id).push(context);
              }
            },
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PagingState<int, Job>>('state', state));
    properties.add(DiagnosticsProperty<WidgetRef>('ref', ref));
    properties.add(DiagnosticsProperty<ValueNotifier<int>>('page', page));
  }
}

class _FilterModal extends HookWidget {
  const _FilterModal({
    required this.searchController,
    required this.searchNode,
    required this.jobTypes,
    required this.jobPositions,
    required this.jobMajors,
    this.jobCity,
  });

  final TextEditingController searchController;

  final FocusNode searchNode;

  final Set<int> jobTypes;

  final Set<int> jobPositions;

  final Set<int> jobMajors;

  final City? jobCity;

  @override
  Widget build(BuildContext context) {
    final jobTypeSelection = useState<Set<int>>(jobTypes);
    final jobPositionSelection = useState<Set<int>>(jobPositions);
    final majorSelection = useState<Set<int>>(jobMajors);
    final citySelection = useState<City?>(jobCity);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(IconlyLight.location, color: Theme.of(context).colorScheme.primaryContainer),
              const SizedBox(width: 8.0),
              Text(
                context.t.auth.location,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(citiesControllerProvider);
              return switch (state) {
                CitiesInitial() => const Center(child: SizedBox.shrink()),
                CitiesLoading() => const Center(child: CircularProgressIndicator()),
                CitiesError() => Center(child: Text(state.message, style: Theme.of(context).textTheme.bodyLarge)),
                CitiesLoaded(cities: final cities) => DropdownButtonField<City?>(
                  value: citySelection.value,
                  items: [
                    DropdownMenuItem<City?>(child: Text('-${context.t.common.chooseALocation}-')),
                    ...cities.map((City value) => DropdownMenuItem<City?>(value: value, child: Text(value.name))),
                  ],
                  label: '-${context.t.common.chooseALocation}-',
                  textBuilder: () {
                    if (citySelection.value != null) {
                      return citySelection.value!.name;
                    }
                    return '-${context.t.common.chooseALocation}-';
                  },
                  onChanged: (City? value) async {
                    citySelection.value = value;
                  },
                ),
              };
            },
          ),
          const SizedBox(height: 24.0),
          Text(
            context.t.job.type,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(scheduleControllerProvider);
              return switch (state) {
                ScheduleInitial() => const Center(child: SizedBox.shrink()),
                ScheduleLoading() => const Center(child: CircularProgressIndicator()),
                ScheduleError() => Center(child: Text(state.message, style: Theme.of(context).textTheme.bodyLarge)),
                ScheduleLoaded(schedules: final schedules) => SizedBox(
                  height: 42.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      return _SelectedOption(label: schedules[index].name, index: index, selection: jobTypeSelection);
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                    itemCount: schedules.length,
                  ),
                ),
              };
            },
          ),
          const SizedBox(height: 24.0),
          Text(
            context.t.job.jobPosition,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(positionControllerProvider);
              return switch (state) {
                PositionInitial() => const Center(child: SizedBox.shrink()),
                PositionLoading() => const Center(child: CircularProgressIndicator()),
                PositionError() => Center(child: Text(state.message, style: Theme.of(context).textTheme.bodyLarge)),
                PositionLoaded(positions: final positions) => SizedBox(
                  height: 42.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      return _SelectedOption(
                        label: positions[index].name,
                        index: index,
                        selection: jobPositionSelection,
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                    itemCount: positions.length,
                  ),
                ),
              };
            },
          ),
          const SizedBox(height: 24.0),
          Text(
            context.t.job.major,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(majorControllerProvider);
              return switch (state) {
                MajorInitial() => const Center(child: SizedBox.shrink()),
                MajorLoading() => const Center(child: CircularProgressIndicator()),
                MajorError() => Center(child: Text(state.message, style: Theme.of(context).textTheme.bodyLarge)),
                MajorLoaded(majors: final majors) => SizedBox(
                  height: 42.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      return _SelectedOption(label: majors[index].name, index: index, selection: majorSelection);
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                    itemCount: majors.length,
                  ),
                ),
              };
            },
          ),
          const SizedBox(height: 50.0),
          Consumer(
            builder: (context, ref, child) {
              return _FilterButton(
                ref: ref,
                searchController: searchController,
                searchNode: searchNode,
                jobTypeSelection: jobTypeSelection,
                jobPositionSelection: jobPositionSelection,
                majorSelection: majorSelection,
                citySelection: citySelection,
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
    properties.add(DiagnosticsProperty<City?>('jobCity', jobCity));
    properties.add(DiagnosticsProperty<TextEditingController>('searchController', searchController));
    properties.add(DiagnosticsProperty<FocusNode>('searchNode', searchNode));
    properties.add(IterableProperty<int>('jobTypes', jobTypes));
    properties.add(IterableProperty<int>('jobPositions', jobPositions));
    properties.add(IterableProperty<int>('jobMajors', jobMajors));
  }
}

class _FilterButton extends StatelessWidget {
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

  final WidgetRef ref;

  final TextEditingController searchController;

  final FocusNode searchNode;

  final ValueNotifier<Set<int>> jobTypeSelection;

  final ValueNotifier<Set<int>> jobPositionSelection;

  final ValueNotifier<Set<int>> majorSelection;

  final ValueNotifier<City?> citySelection;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: () async {
        final majorState = ref.read(majorControllerProvider);
        final positionState = ref.read(positionControllerProvider);
        final scheduleState = ref.read(scheduleControllerProvider);
        final List<Major>? major =
            majorState is MajorLoaded ? majorSelection.value.map((e) => majorState.majors[e]).toList() : null;
        final List<Position>? position =
            positionState is PositionLoaded
                ? jobPositionSelection.value.map((e) => positionState.positions[e]).toList()
                : null;
        final List<Schedule>? schedule =
            scheduleState is ScheduleLoaded
                ? jobTypeSelection.value.map((e) => scheduleState.schedules[e]).toList()
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
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<WidgetRef>('ref', ref));
    properties.add(DiagnosticsProperty<TextEditingController>('searchController', searchController));
    properties.add(DiagnosticsProperty<FocusNode>('searchNode', searchNode));
    properties.add(DiagnosticsProperty<ValueNotifier<Set<int>>>('jobTypeSelection', jobTypeSelection));
    properties.add(DiagnosticsProperty<ValueNotifier<Set<int>>>('jobPositionSelection', jobPositionSelection));
    properties.add(DiagnosticsProperty<ValueNotifier<Set<int>>>('majorSelection', majorSelection));
    properties.add(DiagnosticsProperty<ValueNotifier<City?>>('citySelection', citySelection));
  }
}

class _SelectedOption extends StatelessWidget {
  const _SelectedOption({required this.label, required this.index, required this.selection});

  final String label;

  final int index;

  final ValueNotifier<Set<int>> selection;

  @override
  Widget build(BuildContext context) {
    final isSelected = selection.value.contains(index);
    return FilledButton(
      onPressed: () async {
        if (isSelected) {
          selection.value = selection.value.where((e) => e != index).toSet();
        } else {
          selection.value = {...selection.value, index};
        }
      },
      style: FilledButton.styleFrom(
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(IntProperty('index', index));
    properties.add(DiagnosticsProperty<ValueNotifier<Set<int>>>('selection', selection));
  }
}

class _LanguageSelector extends HookWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final isVietnamese = useState(LocaleSettings.currentLocale == AppLocale.vi);
    return MenuAnchor(
      style: MenuStyle(elevation: WidgetStateProperty.all(4.0)),
      crossAxisUnconstrained: false,
      alignmentOffset: const Offset(0, 8),
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          iconSize: 50.0,
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
        );
      },
      menuChildren: [
        MenuItemButton(
          child: Row(
            spacing: 8.0,
            children: [
              const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircleAvatar(backgroundImage: AssetImage('assets/images/vn.png')),
              ),
              Text('Vietnamese', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          onPressed: () async {
            await LocaleSettings.setLocale(AppLocale.vi);
            isVietnamese.value = true;
          },
        ),
        MenuItemButton(
          child: Row(
            spacing: 8.0,
            children: [
              const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircleAvatar(backgroundImage: AssetImage('assets/images/en.png')),
              ),
              Text('English', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          onPressed: () async {
            await LocaleSettings.setLocale(AppLocale.en);
            isVietnamese.value = false;
          },
        ),
      ],
    );
  }
}
