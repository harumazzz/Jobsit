import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/network/api_constant.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// A simple tile widget to display a piece of information with an icon
class SimpleTile extends StatelessWidget {
  /// Creates a [SimpleTile].
  ///
  /// The [title] and [icon] arguments must not be null.
  const SimpleTile({
    super.key,
    required this.title,
    required this.icon,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  });

  /// The title text to display.
  final String title;

  /// The icon to display next to the title.
  final IconData icon;

  /// The spacing between the icon and the title.
  final double spacing;

  /// The padding around the tile content.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: padding,
    child: Row(
      spacing: spacing,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.onSecondary.withValues(
            alpha: 0.64,
          ),
        ),
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondary.withValues(
                alpha: 0.56,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(DiagnosticsProperty<IconData>('icon', icon))
      ..add(DoubleProperty('spacing', spacing))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  }
}

/// A tile widget specifically designed for displaying job-related information.
/// It typically consists of a title and a child widget for content.
class JobTile extends StatelessWidget {
  /// Creates a [JobTile].
  ///
  /// The [title] and [child] arguments must not be null.
  const JobTile({super.key, required this.title, required this.child});

  /// The title of the job information section.
  final String title;

  /// The widget to display as the content of this job tile.
  final Widget child;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    child: Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary.withValues(
              alpha: 0.64,
            ),
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.workSans(
              fontWeight: FontWeight.w800,
            ).fontFamily,
          ),
        ),
        child,
      ],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

/// A [JobTile] that displays its content in a horizontal scrolling list.
///
/// This is useful for displaying multiple items like positions, majors, or job.
class CarouselJobTile extends StatelessWidget {
  /// Creates a [CarouselJobTile].
  ///
  /// The [title], [count], [builder], and [emptyBuilder].
  const CarouselJobTile({
    super.key,
    required this.title,
    required this.count,
    required this.builder,
    required this.emptyBuilder,
  });

  /// The title of the carousel section.
  final String title;

  /// The number of items in the carousel.
  final int count;

  /// A builder function to create each item in the carousel.
  final Widget Function(BuildContext context, int index) builder;

  /// A builder function to create a widget to display
  final Widget Function(BuildContext context) emptyBuilder;

  @override
  Widget build(final BuildContext context) => JobTile(
    title: title,
    child: count == 0
        ? emptyBuilder(context)
        : SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: builder,
              itemCount: count,
              separatorBuilder: (final context, final index) => const SizedBox(
                width: 4,
              ),
            ),
          ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(IntProperty('count', count))
      ..add(
        ObjectFlagProperty<
          Widget Function(
            BuildContext context,
            int index,
          )
        >.has(
          'builder',
          builder,
        ),
      )
      ..add(
        ObjectFlagProperty<Widget Function(BuildContext context)>.has(
          'emptyBuilder',
          emptyBuilder,
        ),
      );
  }
}

/// A widget to display the user's avatar.
///
/// It shows a cached network image if an avatar URL is available,
/// otherwise, it shows a placeholder or an error widget.
class AvatarSection extends StatelessWidget {
  /// Creates an [AvatarSection].
  ///
  /// The [state] argument must not be null.
  const AvatarSection({super.key, required this.state});

  /// The current authenticated user state, containing user include the avatar.
  final AuthAuthorized state;
  @override
  Widget build(final BuildContext context) => DecoratedBox(
    key: const Key('avatar_section'),
    decoration: BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
    ),
    child: ClipOval(
      child: CachedNetworkImage(
        imageUrl: queryImage(state.user.userInfo.avatar ?? ''),
        width: 86,
        height: 86,
        fit: BoxFit.cover,
        placeholder: (final context, final url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        errorWidget: (final context, final url, final error) => DecoratedBox(
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
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AuthAuthorized>('state', state));
  }
}

/// A widget to display when the user has no avatar.
/// It shows a generic image icon.
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
