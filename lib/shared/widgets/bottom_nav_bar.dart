import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

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
      destinations: const <Widget>[
        NavigationDestination(icon: Icon(IconlyLight.home), label: 'Home'),
        NavigationDestination(icon: Icon(IconlyLight.work), label: 'Applied'),
        NavigationDestination(icon: Icon(IconlyLight.bookmark), label: 'Saved'),
        NavigationDestination(icon: Icon(IconlyLight.profile), label: 'Profile'),
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
