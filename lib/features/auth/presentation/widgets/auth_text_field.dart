import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.focusNode,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    this.autovalidateMode,
  });

  final TextEditingController controller;

  final AutovalidateMode? autovalidateMode;

  final String label;

  final FocusNode focusNode;

  final TextInputType? keyboardType;

  final String? Function(String? value)? validator;

  final void Function(String value)? onFieldSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    properties.add(DiagnosticsProperty<TextInputType?>('keyboardType', keyboardType));
    properties.add(ObjectFlagProperty<String? Function(String? value)?>.has('validator', validator));
    properties.add(ObjectFlagProperty<void Function(String value)?>.has('onFieldSubmitted', onFieldSubmitted));
    properties.add(EnumProperty<AutovalidateMode?>('autovalidateMode', autovalidateMode));
  }
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        labelText: widget.label,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        suffixIcon: _VisibilityButton(
          obscureText: _obscureText,
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      controller: widget.controller,
      obscureText: _obscureText,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  const _VisibilityButton({required this.obscureText, required this.onPressed});

  final bool obscureText;

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(obscureText ? Symbols.visibility_off : Symbols.visibility),
      onPressed: onPressed,
      tooltip: obscureText ? 'Show password' : 'Hide password',
      highlightColor: Colors.transparent,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('obscureText', obscureText));
    properties.add(ObjectFlagProperty<void Function()>.has('onPressed', onPressed));
  }
}
