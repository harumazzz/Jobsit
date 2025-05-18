import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../i18n/strings.g.dart';

class BottomNavBar extends HookWidget {
  const BottomNavBar({super.key, required this.index, required this.onTap});

  final int index;

  final void Function(int value) onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onTap,
      indicatorColor: Colors.amber,
      selectedIndex: index,
      destinations: <Widget>[
        NavigationDestination(icon: const Icon(IconlyLight.home), label: context.t.common.home),
        NavigationDestination(icon: const Icon(IconlyLight.work), label: context.t.common.applied),
        NavigationDestination(icon: const Icon(IconlyLight.bookmark), label: context.t.common.saved),
        NavigationDestination(icon: const Icon(IconlyLight.profile), label: context.t.common.profile),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
    properties.add(ObjectFlagProperty<void Function(int value)>.has('onTap', onTap));
  }
}
