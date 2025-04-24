import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/shared_prefs_service.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
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
        padding: const EdgeInsets.all(8.0),
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
                  const SizedBox(
                    width: 57.0,
                    height: 49.0,
                    child: CircleAvatar(backgroundImage: AssetImage('assets/images/vn.png'), radius: 24.5),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            SliverToBoxAdapter(
              child: Row(
                spacing: 16.0,
                children: [
                  Expanded(
                    child: SearchBar(
                      leading: const Icon(IconlyLight.search),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      hintText: 'Search Job',
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      elevation: const WidgetStatePropertyAll(1.0),
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    child: const Icon(IconlyLight.filter),
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
