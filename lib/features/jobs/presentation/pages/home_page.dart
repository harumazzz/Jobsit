import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/shared_prefs_service.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/pages/profile_page.dart';
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

class _JobPage extends StatelessWidget {
  const _JobPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      hintText: 'Search Job',
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
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    tooltip: 'Filter',
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                      side: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
                    ),
                    elevation: 2.0,
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return const _FilterModal();
                        },
                      );
                    },
                    child: Icon(IconlyLight.filter, color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterModal extends HookWidget {
  const _FilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    final jobTypeSelection = useState<int>(0);
    final jobPositionSelection = useState<int>(0);
    final majorSelection = useState<int>(0);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(IconlyLight.location, color: Theme.of(context).colorScheme.primaryContainer),
                const SizedBox(width: 8.0),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            DropdownButtonField<String>(
              items: [
                ...['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }),
              ],
              label: '-Choose a location-',
              onChanged: (String? value) {
                // TODO(self): Implement location filter functionality
              },
            ),
            const SizedBox(height: 24.0),
            Text(
              'Job Type',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 42.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  return _SelectedOption(label: 'Option $index', index: index, selection: jobTypeSelection);
                },
                separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                itemCount: 3,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Job Position',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 42.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  return _SelectedOption(label: 'Option $index', index: index, selection: jobPositionSelection);
                },
                separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                itemCount: 3,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Major',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 42.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  return _SelectedOption(label: 'Option $index', index: index, selection: majorSelection);
                },
                separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                itemCount: 3,
              ),
            ),
            const SizedBox(height: 50.0),
            CustomButton(
              onPressed: () async {
                // TODO(self): Implement filter
                Navigator.of(context).pop();
              },
              child: const Center(child: Text('Apply filter')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedOption extends StatelessWidget {
  const _SelectedOption({super.key, required this.label, required this.index, required this.selection});

  final String label;

  final int index;

  final ValueNotifier<int> selection;

  @override
  Widget build(BuildContext context) {
    final isSelected = selection.value == index;
    return FilledButton(
      onPressed: () async {
        selection.value = index;
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
    properties.add(DiagnosticsProperty<ValueNotifier<int>>('selection', selection));
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
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
          icon: const CircleAvatar(backgroundImage: AssetImage('assets/images/vn.png')),
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
            // TODO(self): Implement language change to Vietnamese
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
            // TODO(self): Implement language change to English
          },
        ),
      ],
    );
  }
}
