import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../i18n/strings.g.dart';

/// A custom bottom navigation bar widget.
///
/// Displays navigation destinations for Home, Applied, Saved, and Profile
class BottomNavBar extends HookWidget {
  /// Creates a [BottomNavBar].
  ///
  /// The [index] indicates the currently selected destination.
  /// The [onTap] callback is invoked when a destination is selected.
  const BottomNavBar({super.key, required this.index, required this.onTap});

  /// The index of the currently selected navigation destination.
  final int index;

  /// Callback function that is called when a destination is selected
  ///
  /// The `value` parameter is the index of the selected destination.
  final void Function(int value) onTap;

  @override
  Widget build(final BuildContext context) => NavigationBar(
    onDestinationSelected: onTap,
    indicatorColor: Colors.amber,
    selectedIndex: index,
    destinations: <Widget>[
      NavigationDestination(
        icon: const Icon(IconlyLight.home),
        label: context.t.common.home,
      ),
      NavigationDestination(
        icon: const Icon(IconlyLight.work),
        label: context.t.common.applied,
      ),
      NavigationDestination(
        icon: const Icon(IconlyLight.bookmark),
        label: context.t.common.saved,
      ),
      NavigationDestination(
        key: const Key('profile_tab'),
        icon: const Icon(IconlyLight.profile),
        label: context.t.common.profile,
      ),
    ],
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('index', index))
      ..add(ObjectFlagProperty<void Function(int value)>.has('onTap', onTap));
  }
}
