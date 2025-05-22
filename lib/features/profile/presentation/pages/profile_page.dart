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

/// The main page for displaying user profile information.
///
/// This page shows the user's avatar, name, job statistics
/// personal information, job information, and provides options to edit them.
/// It also allows users to manage settings like job search visibility and email
/// change their password, and log out.
class ProfilePage extends HookConsumerWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    if (ref.read(authControllerProvider) is! AuthAuthorized) {
      return const _ProfileShimmer();
    }
    final state = ref.read(authControllerProvider) as AuthAuthorized;
    final allowSearch = useState(state.user.jobInfo.searchable);
    final emailNotification = useState(state.user.userInfo.mailReceive);
    final isSearchableLoading = useState(false);
    final isMailReceiveLoading = useState(false);
    final isSelectedJobEdit = useState(false);
    final isSelectedProfileEdit = useState(false);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 38,
          floating: true,
          backgroundColor: const Color(0xFFefeff0),
          surfaceTintColor: const Color(0xFff5fafd),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(context.t.profile.title),
            centerTitle: true,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverToBoxAdapter(
            child: Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer(
                  builder:
                      // ignore: lines_longer_than_80_chars
                      (final context, final ref, final child) => switch (ref.watch(authControllerProvider)) {
                        final AuthAuthorized state =>
                          state.user.userInfo.avatar != null
                              ? AvatarSection(state: state)
                              : DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: const _NoAvatar(),
                              ),
                        _ => const CircularProgressIndicator.adaptive(),
                      },
                ),

                Consumer(
                  builder:
                      // ignore: lines_longer_than_80_chars
                      (final context, final ref, final child) => switch (ref.watch(authControllerProvider)) {
                        final AuthAuthorized state => Text(
                          // ignore: lines_longer_than_80_chars
                          '${state.user.userInfo.firstName} ${state.user.userInfo.lastName}',
                          // ignore: lines_longer_than_80_chars
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _ => const CircularProgressIndicator.adaptive(),
                      },
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                _CustomIcon(
                  title: context.t.job.applied,
                  subtitle: switch (ref.watch(applyJobControllerProvider)) {
                    ApplyJobLoaded(jobs: final jobs) => jobs.length.toString(),
                    _ => '0',
                  },
                  icon: Icon(
                    IconlyLight.profile,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                _CustomIcon(
                  title: context.t.job.saved,
                  subtitle: switch (ref.watch(savedJobControllerProvider)) {
                    SavedJobLoaded(jobs: final jobs) => jobs.length.toString(),
                    _ => '0',
                  },
                  icon: Icon(
                    IconlyLight.work,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        _JobModifier(
          allowSearch: allowSearch,
          isSearchableLoading: isSearchableLoading,
          ref: ref,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: _EmailSwitcher(
              emailNotification: emailNotification,
              isMailReceiveLoading: isMailReceiveLoading,
              ref: ref,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    context.t.profile.personalInformation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.t.common.edit,
                  onPressed: () async {
                    if (isSelectedProfileEdit.value) {
                      return;
                    }
                    isSelectedProfileEdit.value = true;
                    // ignore: lines_longer_than_80_chars
                    await ref.read(citiesControllerProvider.notifier).fetchCities();
                    // ignore: lines_longer_than_80_chars
                    await ref.read(universityControllerProvider.notifier).getUniversities();
                    if (context.mounted) {
                      await const EditProfileRoute().push(context);
                    }
                    isSelectedProfileEdit.value = false;
                  },
                  icon: Icon(
                    IconlyLight.editSquare,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Consumer(
              builder:
                  // ignore: lines_longer_than_80_chars
                  (final context, final ref, final child) => switch (ref.watch(authControllerProvider)) {
                    final AuthAuthorized state => _InfoCard(state: state),
                    _ => const CircularProgressIndicator.adaptive(),
                  },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.t.job.information,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: context.t.common.edit,
                  onPressed: () async {
                    if (isSelectedJobEdit.value) {
                      return;
                    }
                    isSelectedJobEdit.value = true;
                    // ignore: lines_longer_than_80_chars
                    await ref.read(citiesControllerProvider.notifier).fetchCities();
                    if (context.mounted) {
                      await const EditJobRoute().push(context);
                    }
                    isSelectedJobEdit.value = false;
                  },
                  icon: Icon(
                    IconlyLight.editSquare,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Consumer(
              builder: (final context, final ref, final child) {
                final it = ref.watch(authControllerProvider);
                return switch (it) {
                  final AuthAuthorized state => _JobCard(state: state),
                  _ => const CircularProgressIndicator.adaptive(),
                };
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: CustomButton(
              color: Theme.of(context).colorScheme.onSecondary.withValues(
                alpha: 0.24,
              ),
              onPressed: () async {
                await const ChangePasswordRoute().push(context);
              },
              child: Text(context.t.auth.changePassword),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: CustomButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logOut();
                ref
                  ..invalidate(searchJobsControllerProvider)
                  ..invalidate(savedJobControllerProvider)
                  ..invalidate(jobFilterControllerProvider)
                  ..invalidate(searchJobsControllerProvider)
                  ..invalidate(applyJobControllerProvider);
                if (context.mounted) {
                  NotificationService.info(
                    context: context,
                    message: context.t.login.logout,
                  );
                  const LoginRoute().go(context);
                }
              },
              child: Text(context.t.auth.logout),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }
}

/// A card widget to display the user's personal information.
class _InfoCard extends StatelessWidget {
  /// Creates an [_InfoCard].
  const _InfoCard({required this.state});

  /// The current authenticated user state.
  final AuthAuthorized state;

  @override
  Widget build(final BuildContext context) => Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 1,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        SimpleTile(title: state.user.userInfo.email, icon: IconlyLight.message),
        SimpleTile(title: state.user.userInfo.phone, icon: IconlyLight.calling),
        SimpleTile(
          title: state.user.userInfo.address ?? 'No address',
          icon: IconlyLight.location,
        ),
        SimpleTile(
          title:
              // ignore: lines_longer_than_80_chars
              state.user.jobInfo.university == null ? context.t.auth.university : state.user.jobInfo.university!.name,
          icon: IconlyLight.home,
        ),
        SimpleTile(title: state.user.userInfo.birthDate ?? '01/01/2000', icon: IconlyLight.calendar),
        SimpleTile(
          // ignore: lines_longer_than_80_chars
          title: state.user.userInfo.gender ? context.t.profile.female : context.t.profile.male,
          icon: IconlyLight.profile,
        ),
        const SizedBox(height: 8),
      ],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AuthAuthorized>('state', state));
  }
}

/// A switch tile widget for toggling email notifications.
class _EmailSwitcher extends StatelessWidget {
  /// Creates an [_EmailSwitcher].
  const _EmailSwitcher({
    super.key,
    required this.emailNotification,
    required this.isMailReceiveLoading,
    required this.ref,
  });

  /// A [ValueNotifier] that holds the current state of email notifications (enabled/disabled).
  final ValueNotifier<bool> emailNotification;

  /// A [ValueNotifier] that indicates if the mail receive status is updated
  final ValueNotifier<bool> isMailReceiveLoading;

  /// A [WidgetRef] to interact with Riverpod providers.
  final WidgetRef ref;

  @override
  Widget build(final BuildContext context) => SwitchListTile.adaptive(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    value: emailNotification.value,
    onChanged: (final bool? value) async {
      if (isMailReceiveLoading.value) {
        return;
      }
      if (value == null) {
        return;
      }
      isMailReceiveLoading.value = true;
      emailNotification.value = value;
      try {
        await ref
            .read(authControllerProvider.notifier)
            .updateMailReceive(
              mailReceive: value,
            );
      } finally {
        isMailReceiveLoading.value = false;
      }
    },
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<bool>>(
          'emailNotification',
          emailNotification,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<bool>>(
          'isMailReceiveLoading',
          isMailReceiveLoading,
        ),
      )
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref));
  }
}

/// A card widget to display the user's job-related information.
class _JobCard extends StatelessWidget {
  /// Creates a [_JobCard].
  const _JobCard({super.key, required this.state});

  /// The current authenticated user state.
  final AuthAuthorized state;

  @override
  Widget build(final BuildContext context) => Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 1,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const SizedBox(height: 8),
        JobTile(
          title: context.t.job.wanted,
          child: Text(
            state.user.jobInfo.desiredJob ?? context.t.job.noJobDesire,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        CarouselJobTile(
          title: context.t.job.position,
          count: state.user.jobInfo.positions.length,
          emptyBuilder: (_) => Text(context.t.profile.noPosition),
          builder:
              (final context, final index) => DisabledButton(
                title: state.user.jobInfo.positions[index].name,
              ),
        ),
        CarouselJobTile(
          title: context.t.job.major,
          count: state.user.jobInfo.majors.length,
          emptyBuilder: (_) => Text(context.t.profile.noMajor),
          builder:
              (final context, final index) => DisabledButton(
                title: state.user.jobInfo.majors[index].name,
              ),
        ),
        CarouselJobTile(
          title: context.t.job.type,
          count: state.user.jobInfo.schedules.length,
          emptyBuilder: (_) => Text(context.t.profile.noType),
          builder:
              (final context, final index) => DisabledButton(
                title: state.user.jobInfo.schedules[index].name,
              ),
        ),
        JobTile(
          title: context.t.auth.location,
          child: SimpleTile(
            icon: IconlyLight.location,
            // ignore: lines_longer_than_80_chars
            title: state.user.jobInfo.desiredWorkingProvince ?? context.t.auth.city,
            spacing: 8,
            padding: EdgeInsets.zero,
          ),
        ),
        JobTile(
          title: context.t.job.cv,
          child: SizedBox(
            height: 40,
            child: DisabledButton(
              title: state.user.jobInfo.cv ?? context.t.profile.noCv,
            ),
          ),
        ),
        JobTile(
          title: context.t.job.coverLetter.title,
          child: SizedBox(
            height: 40,
            child: Text(
              // ignore: lines_longer_than_80_chars
              state.user.jobInfo.referenceLetter ?? context.t.job.noReferenceLetter,
            ),
          ),
        ),
        const SizedBox.shrink(),
      ],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AuthAuthorized>('state', state));
  }
}

/// A widget for modifying the job searchability status.
class _JobModifier extends StatelessWidget {
  /// Creates a [_JobModifier].
  const _JobModifier({
    super.key,
    required this.allowSearch,
    required this.isSearchableLoading,
    required this.ref,
  });

  /// A [ValueNotifier] that holds the current state of job search allowance.
  final ValueNotifier<bool> allowSearch;

  /// A [ValueNotifier] that indicates if the searchable status is updated.
  final ValueNotifier<bool> isSearchableLoading;

  /// A [WidgetRef] to interact with Riverpod providers.
  final WidgetRef ref;

  @override
  Widget build(final BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    sliver: SliverToBoxAdapter(
      child: SwitchListTile.adaptive(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        trackColor: WidgetStatePropertyAll(
          allowSearch.value
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSecondary.withValues(
                alpha: 0.24,
              ),
        ),
        thumbColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.onPrimary,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        title: Text(
          context.t.job.allowSearch,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        value: allowSearch.value,
        onChanged: (final bool? value) async {
          if (isSearchableLoading.value) {
            return;
          }
          if (value == null) {
            return;
          }
          allowSearch.value = value;
          isSearchableLoading.value = true;
          try {
            await ref
                .read(authControllerProvider.notifier)
                .updateSearchable(
                  searchable: value,
                );
          } finally {
            isSearchableLoading.value = false;
          }
        },
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<bool>>(
          'allowSearch',
          allowSearch,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<bool>>(
          'isSearchableLoading',
          isSearchableLoading,
        ),
      )
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref));
  }
}

/// A widget to display when the user has no avatar.
class _NoAvatar extends StatelessWidget {
  /// Creates a [_NoAvatar] widget.
  const _NoAvatar();

  @override
  Widget build(final BuildContext context) => Icon(
    IconlyLight.image,
    size: 48,
    color: Theme.of(context).colorScheme.onSecondary.withValues(
      alpha: 0.64,
    ),
  );
}

/// A custom icon widget used in the profile page to display statistics.
class _CustomIcon extends StatelessWidget {
  /// Creates a [_CustomIcon].
  const _CustomIcon({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  /// The icon to display.
  final Widget icon;

  /// The title text to display below the icon.
  final String title;

  /// The subtitle text (usually a count) to display below the title.
  final String subtitle;

  @override
  Widget build(final BuildContext context) => Column(
    children: [
      SizedBox(
        width: 140,
        height: 47,
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          radius: 12,
          child: icon,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        subtitle,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(StringProperty('subtitle', subtitle));
  }
}

/// A shimmer widget displayed while the profile data is loading.
class _ProfileShimmer extends StatelessWidget {
  /// Creates a [_ProfileShimmer].
  const _ProfileShimmer();

  @override
  Widget build(final BuildContext context) => CustomScrollView(
    slivers: [
      const SliverAppBar(
        expandedHeight: 38,
        floating: true,
        backgroundColor: Color(0xFFefeff0),
        surfaceTintColor: Color(0xFff5fafd),
        flexibleSpace: FlexibleSpaceBar(
          title: Text('Profile'),
          centerTitle: true,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverToBoxAdapter(
          child: Column(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: const _NoAvatar(),
                ),
              ),
              const SizedBox(height: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: _CustomIcon(
                  title: context.t.job.applied,
                  subtitle: '0',
                  icon: Icon(
                    IconlyLight.profile,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: _CustomIcon(
                  title: context.t.job.saved,
                  subtitle: '0',
                  icon: Icon(
                    IconlyLight.work,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 180,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ],
  );
}
