import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, required this.child});

  final void Function()? onPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)))),
      ),
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function()?>.has('onPressed', onPressed));
  }
}
