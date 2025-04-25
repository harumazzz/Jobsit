import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleTile extends StatelessWidget {
  const SimpleTile({
    super.key,
    required this.title,
    required this.icon,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
  });

  final String title;

  final IconData icon;

  final double spacing;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        spacing: spacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24.0, color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.64)),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.56),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
  }
}

class JobTile extends StatelessWidget {
  const JobTile({super.key, required this.title, required this.child});

  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Column(
        spacing: 4.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.64),
              fontWeight: FontWeight.w700,
              fontFamily: GoogleFonts.workSans(fontWeight: FontWeight.w800).fontFamily,
            ),
          ),
          child,
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class CarouselJobTile extends StatelessWidget {
  const CarouselJobTile({
    super.key,
    required this.title,
    required this.count,
    required this.builder,
    required this.emptyBuilder,
  });

  final String title;

  final int count;

  final Widget Function(BuildContext context, int index) builder;

  final Widget Function(BuildContext context) emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return JobTile(
      title: title,
      child:
          count == 0
              ? emptyBuilder(context)
              : SizedBox(
                height: 32.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: builder,
                  itemCount: count,
                  separatorBuilder: (context, index) => const SizedBox(width: 4.0),
                ),
              ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(IntProperty('count', count));
    properties.add(ObjectFlagProperty<Widget Function(BuildContext context, int index)>.has('builder', builder));
    properties.add(ObjectFlagProperty<Widget Function(BuildContext context)>.has('emptyBuilder', emptyBuilder));
  }
}
