import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_info_tile.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(authControllerProvider) is! AuthAuthorized) {
      return const _ProfileShimmer();
    }
    final state = ref.read(authControllerProvider) as AuthAuthorized;
    final allowSearch = useState(state.user.jobInfo.searchable);
    final emailNotification = useState(state.user.userInfo.mailReceive);
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 38.0,
          floating: true,
          backgroundColor: Color(0xFFefeff0),
          flexibleSpace: FlexibleSpaceBar(title: Text('Profile'), centerTitle: true),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              spacing: 4.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 86.0,
                  height: 86.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                  ),
                  child: const _NoAvatar(),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    return switch (ref.watch(authControllerProvider)) {
                      AuthAuthorized state => Text(
                        '${state.user.userInfo.firstName} ${state.user.userInfo.lastName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      _ => const CircularProgressIndicator.adaptive(),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0,
              children: [
                _CustomIcon(
                  title: 'Applied',
                  subtitle: '0',
                  icon: Icon(IconlyLight.profile, size: 24.0, color: Theme.of(context).colorScheme.onPrimary),
                ),
                _CustomIcon(
                  title: 'Saved',
                  subtitle: '0',
                  icon: Icon(IconlyLight.work, size: 24.0, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: SwitchListTile.adaptive(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              trackColor: WidgetStatePropertyAll(
                allowSearch.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.24),
              ),
              thumbColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              title: Text(
                'Allow employers to search your profile',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              value: allowSearch.value,
              onChanged: (bool? value) async {
                if (value == null) {
                  return;
                }
                allowSearch.value = value;
                await ref.read(authControllerProvider.notifier).updateSearchable(searchable: value);
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: SwitchListTile.adaptive(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              trackColor: WidgetStatePropertyAll(
                emailNotification.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.24),
              ),
              thumbColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              title: Text(
                'Email notification',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              value: emailNotification.value,
              onChanged: (bool? value) async {
                if (value == null) {
                  return;
                }
                emailNotification.value = value;
                await ref.read(authControllerProvider.notifier).updateMailReceive(mailReceive: value);
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () async {
                    // TODO(self): Implement the logic to edit the profile
                  },
                  icon: Icon(IconlyLight.editSquare, size: 24.0, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                return switch (ref.watch(authControllerProvider)) {
                  AuthAuthorized state => Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    elevation: 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8.0),
                        SimpleTile(title: state.user.userInfo.email, icon: IconlyLight.message),
                        SimpleTile(title: state.user.userInfo.phone, icon: IconlyLight.calling),
                        SimpleTile(title: state.user.userInfo.address ?? 'No address', icon: IconlyLight.location),
                        SimpleTile(
                          title:
                              state.user.jobInfo.university == null
                                  ? 'University'
                                  : state.user.jobInfo.university!.name,
                          icon: IconlyLight.home,
                        ),
                        SimpleTile(title: state.user.userInfo.birthDate ?? '01/01/2000', icon: IconlyLight.calendar),
                        SimpleTile(title: state.user.userInfo.gender ? 'Female' : 'Male', icon: IconlyLight.profile),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  _ => const CircularProgressIndicator.adaptive(),
                };
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Job Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () async {
                    // TODO(self): Implement the logic to edit the profile
                  },
                  icon: Icon(IconlyLight.editSquare, size: 24.0, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                return switch (ref.watch(authControllerProvider)) {
                  AuthAuthorized state => Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    elevation: 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.0,
                      children: [
                        const SizedBox(height: 8.0),
                        JobTile(
                          title: 'Job wanted',
                          child: Text(
                            state.user.jobInfo.desiredJob ?? 'Something',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                        CarouselJobTile(
                          title: 'Position',
                          count: state.user.jobInfo.positions.length,
                          emptyBuilder: (_) => const Text('No positions available'),
                          builder: (context, index) {
                            return DisabledButton(title: state.user.jobInfo.positions[index].toString());
                          },
                        ),
                        CarouselJobTile(
                          title: 'Major',
                          count: state.user.jobInfo.majors.length,
                          emptyBuilder: (_) => const Text('No majors available'),
                          builder: (context, index) {
                            return DisabledButton(title: state.user.jobInfo.positions[index].toString());
                          },
                        ),
                        CarouselJobTile(
                          title: 'Job type',
                          count: state.user.jobInfo.schedules.length,
                          emptyBuilder: (_) => const Text('No job type available'),
                          builder: (context, index) {
                            return DisabledButton(title: state.user.jobInfo.schedules[index].toString());
                          },
                        ),
                        JobTile(
                          title: 'Job location',
                          child: SimpleTile(
                            icon: IconlyLight.location,
                            title: state.user.jobInfo.desiredWorkingProvince ?? 'City',
                            spacing: 8.0,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        JobTile(
                          title: 'CV',
                          child: SizedBox(height: 40.0, child: DisabledButton(title: state.user.jobInfo.cv ?? 'No CV')),
                        ),
                        JobTile(
                          title: 'Cover letter',
                          child: SizedBox(
                            height: 40.0,
                            child: Text(state.user.jobInfo.referenceLetter ?? 'No cover letter'),
                          ),
                        ),
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  _ => const CircularProgressIndicator.adaptive(),
                };
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: CustomButton(
              color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.24),
              onPressed: () async {
                // TODO(self): Implement the logic to change password
              },
              child: const Text('Change Password'),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: CustomButton(
              onPressed: () async {
                // TODO(self): Implement the logic to logout
              },
              child: const Text('Log Out'),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
      ],
    );
  }
}

class _NoAvatar extends StatelessWidget {
  const _NoAvatar();

  @override
  Widget build(BuildContext context) {
    return Icon(
      IconlyLight.image,
      size: 48.0,
      color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.64),
    );
  }
}

class _CustomIcon extends StatelessWidget {
  const _CustomIcon({required this.title, required this.subtitle, required this.icon});

  final Widget icon;

  final String title;

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 140.0,
          height: 47.0,
          child: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary, radius: 12.0, child: icon),
        ),
        const SizedBox(height: 4.0),
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w300)),
        const SizedBox(height: 2.0),
        Text(subtitle, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('subtitle', subtitle));
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 38.0,
          floating: true,
          backgroundColor: Color(0xFFefeff0),
          flexibleSpace: FlexibleSpaceBar(title: Text('Profile'), centerTitle: true),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              spacing: 4.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 86.0,
                  height: 86.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: const _NoAvatar(),
                  ),
                ),
                const SizedBox(height: 8.0),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120.0,
                    height: 16.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: _CustomIcon(
                    title: 'Applied',
                    subtitle: '0',
                    icon: Icon(IconlyLight.profile, size: 24.0, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: _CustomIcon(
                    title: 'Saved',
                    subtitle: '0',
                    icon: Icon(IconlyLight.work, size: 24.0, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 180.0,
                    height: 20.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 220.0,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150.0,
                    height: 20.0,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 280.0,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
      ],
    );
  }
}
