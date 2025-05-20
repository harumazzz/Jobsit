import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../jobs/presentation/providers/job_provider.dart';
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
    final isSearchableLoading = useState(false);
    final isMailReceiveLoading = useState(false);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 38.0,
          floating: true,
          backgroundColor: const Color(0xFFefeff0),
          surfaceTintColor: const Color(0xFff5fafd),
          flexibleSpace: FlexibleSpaceBar(title: Text(context.t.profile.title), centerTitle: true),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              spacing: 4.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    return switch (ref.watch(authControllerProvider)) {
                      AuthAuthorized state =>
                        state.user.userInfo.avatar != null
                            ? AvatarSection(state: state)
                            : Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                              ),
                              child: const _NoAvatar(),
                            ),
                      _ => const CircularProgressIndicator.adaptive(),
                    };
                  },
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
                  title: context.t.job.applied,
                  subtitle: switch (ref.watch(applyJobControllerProvider)) {
                    ApplyJobLoaded(jobs: final jobs) => jobs.length.toString(),
                    _ => '0',
                  },
                  icon: Icon(IconlyLight.profile, size: 24.0, color: Theme.of(context).colorScheme.onPrimary),
                ),
                _CustomIcon(
                  title: context.t.job.saved,
                  subtitle: switch (ref.watch(savedJobControllerProvider)) {
                    SavedJobLoaded(jobs: final jobs) => jobs.length.toString(),
                    _ => '0',
                  },
                  icon: Icon(IconlyLight.work, size: 24.0, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
        _JobModifier(allowSearch: allowSearch, isSearchableLoading: isSearchableLoading, ref: ref),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: _EmailSwitcher(
              emailNotification: emailNotification,
              isMailReceiveLoading: isMailReceiveLoading,
              ref: ref,
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
                    context.t.profile.personalInformation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: context.t.common.edit,
                  onPressed: () async {
                    await ref.read(citiesControllerProvider.notifier).fetchCities();
                    await ref.read(universityControllerProvider.notifier).getUniversities();
                    if (context.mounted) {
                      await const EditProfileRoute().push(context);
                    }
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
                  AuthAuthorized state => _InfoCard(state: state),
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
                  context.t.job.information,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: context.t.common.edit,
                  onPressed: () async {
                    await ref.read(citiesControllerProvider.notifier).fetchCities();
                    if (context.mounted) {
                      await const EditJobRoute().push(context);
                    }
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
                  AuthAuthorized state => _JobCard(state: state),
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
                await const ChangePasswordRoute().push(context);
              },
              child: Text(context.t.auth.changePassword),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: CustomButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logOut();
                ref.invalidate(searchJobsControllerProvider);
                ref.invalidate(savedJobControllerProvider);
                ref.invalidate(jobFilterControllerProvider);
                ref.invalidate(searchJobsControllerProvider);
                ref.invalidate(applyJobControllerProvider);
                if (context.mounted) {
                  NotificationService.info(context: context, message: context.t.login.logout);
                  const LoginRoute().go(context);
                }
              },
              child: Text(context.t.auth.logout),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.state});

  final AuthAuthorized state;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                state.user.jobInfo.university == null ? context.t.auth.university : state.user.jobInfo.university!.name,
            icon: IconlyLight.home,
          ),
          SimpleTile(title: state.user.userInfo.birthDate ?? '01/01/2000', icon: IconlyLight.calendar),
          SimpleTile(
            title: state.user.userInfo.gender ? context.t.profile.female : context.t.profile.male,
            icon: IconlyLight.profile,
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AuthAuthorized>('state', state));
  }
}

class _EmailSwitcher extends StatelessWidget {
  const _EmailSwitcher({
    super.key,
    required this.emailNotification,
    required this.isMailReceiveLoading,
    required this.ref,
  });

  final ValueNotifier<bool> emailNotification;

  final ValueNotifier<bool> isMailReceiveLoading;

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
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
        context.t.job.emailNotification,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      value: emailNotification.value,
      onChanged: (bool? value) async {
        if (isMailReceiveLoading.value) {
          return;
        }
        if (value == null) {
          return;
        }
        isMailReceiveLoading.value = true;
        emailNotification.value = value;
        try {
          await ref.read(authControllerProvider.notifier).updateMailReceive(mailReceive: value);
        } finally {
          isMailReceiveLoading.value = false;
        }
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('emailNotification', emailNotification));
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('isMailReceiveLoading', isMailReceiveLoading));
    properties.add(DiagnosticsProperty<WidgetRef>('ref', ref));
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({super.key, required this.state});

  final AuthAuthorized state;

  @override
  Widget build(BuildContext context) {
    return Card(
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
            title: context.t.job.wanted,
            child: Text(
              state.user.jobInfo.desiredJob ?? '',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
            ),
          ),
          CarouselJobTile(
            title: context.t.job.position,
            count: state.user.jobInfo.positions.length,
            emptyBuilder: (_) => Text(context.t.profile.noPosition),
            builder: (context, index) {
              return DisabledButton(title: state.user.jobInfo.positions[index].name);
            },
          ),
          CarouselJobTile(
            title: context.t.job.major,
            count: state.user.jobInfo.majors.length,
            emptyBuilder: (_) => Text(context.t.profile.noMajor),
            builder: (context, index) {
              return DisabledButton(title: state.user.jobInfo.majors[index].name);
            },
          ),
          CarouselJobTile(
            title: context.t.job.type,
            count: state.user.jobInfo.schedules.length,
            emptyBuilder: (_) => Text(context.t.profile.noType),
            builder: (context, index) {
              return DisabledButton(title: state.user.jobInfo.schedules[index].name);
            },
          ),
          JobTile(
            title: context.t.auth.location,
            child: SimpleTile(
              icon: IconlyLight.location,
              title: state.user.jobInfo.desiredWorkingProvince ?? context.t.auth.city,
              spacing: 8.0,
              padding: EdgeInsets.zero,
            ),
          ),
          JobTile(
            title: context.t.job.cv,
            child: SizedBox(
              height: 40.0,
              child: DisabledButton(title: state.user.jobInfo.cv ?? context.t.profile.noCv),
            ),
          ),
          JobTile(
            title: context.t.job.coverLetter.title,
            child: SizedBox(height: 40.0, child: Text(state.user.jobInfo.referenceLetter ?? '')),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AuthAuthorized>('state', state));
  }
}

class _JobModifier extends StatelessWidget {
  const _JobModifier({super.key, required this.allowSearch, required this.isSearchableLoading, required this.ref});

  final ValueNotifier<bool> allowSearch;

  final ValueNotifier<bool> isSearchableLoading;

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
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
            context.t.job.allowSearch,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          value: allowSearch.value,
          onChanged: (bool? value) async {
            if (isSearchableLoading.value) {
              return;
            }
            if (value == null) {
              return;
            }
            allowSearch.value = value;
            isSearchableLoading.value = true;
            try {
              await ref.read(authControllerProvider.notifier).updateSearchable(searchable: value);
            } finally {
              isSearchableLoading.value = false;
            }
          },
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('allowSearch', allowSearch));
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('isSearchableLoading', isSearchableLoading));
    properties.add(DiagnosticsProperty<WidgetRef>('ref', ref));
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
          surfaceTintColor: Color(0xFff5fafd),
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
                    title: context.t.job.applied,
                    subtitle: '0',
                    icon: Icon(IconlyLight.profile, size: 24.0, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: _CustomIcon(
                    title: context.t.job.saved,
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
