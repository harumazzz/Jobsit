import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/utils/input_converter.dart';
import '../providers/auth_provider.dart';

class AuthTextField extends HookWidget {
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

  @override
  Widget build(BuildContext context) {
    final obscureText = useState(true);
    return TextFormField(
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        suffixIcon: _VisibilityButton(
          obscureText: obscureText.value,
          onPressed: () async {
            obscureText.value = !obscureText.value;
            if (obscureText.value) {
              focusNode.requestFocus();
            } else {
              focusNode.unfocus();
            }
          },
        ),
      ),
      controller: controller,
      obscureText: obscureText.value,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
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

class RegisterEmailTextField extends ConsumerStatefulWidget {
  const RegisterEmailTextField({super.key, required this.controller, required this.focusNode, this.onFieldSubmitted});

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String value)? onFieldSubmitted;

  @override
  ConsumerState<RegisterEmailTextField> createState() => _RegisterEmailTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    properties.add(ObjectFlagProperty<void Function(String value)?>.has('onFieldSubmitted', onFieldSubmitted));
  }
}

class _RegisterEmailTextFieldState extends ConsumerState<RegisterEmailTextField> {
  late PublishSubject<String> _emailSubject;
  bool _isCheckingEmail = false;
  bool _isEmailAvailable = true;
  String? _emailErrorText;

  @override
  void initState() {
    super.initState();
    _emailSubject = PublishSubject<String>();
    _emailSubject.debounceTime(const Duration(milliseconds: 800)).listen(_checkEmailAvailability);
    widget.controller.addListener(_onEmailChanged);
  }

  void _onEmailChanged() async {
    final email = widget.controller.text;
    if (email.isEmpty || InputConverter.validateEmail(email) != null) {
      setState(() {
        _isCheckingEmail = false;
        _isEmailAvailable = true;
        _emailErrorText = null;
      });
      return;
    }
    setState(() {
      _isCheckingEmail = true;
      _emailErrorText = null;
    });
    _emailSubject.add(email);
  }

  void _checkEmailAvailability(String email) async {
    try {
      final result = await ref.read(authControllerProvider.notifier).checkEmailExists(email);
      setState(() {
        _isCheckingEmail = false;
        _isEmailAvailable = !result.toLowerCase().contains('đã sử dụng');
        _emailErrorText = _isEmailAvailable ? null : 'Email already exists';
      });
    } catch (e) {
      setState(() {
        _isCheckingEmail = false;
        _emailErrorText = null;
      });
    }
  }

  @override
  void dispose() {
    _emailSubject.close();
    widget.controller.removeListener(_onEmailChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        labelText: 'Email',
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        errorText: _emailErrorText,
        suffixIcon:
            _isCheckingEmail
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(padding: EdgeInsets.all(10.0), child: CircularProgressIndicator(strokeWidth: 2)),
                )
                : _isEmailAvailable &&
                    widget.controller.text.isNotEmpty &&
                    InputConverter.validateEmail(widget.controller.text) == null
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
      ),
      validator: (value) {
        final basicValidation = InputConverter.validateEmail(value);
        if (basicValidation != null) {
          return basicValidation;
        }
        if (!_isEmailAvailable) {
          return 'Email already exists';
        }
        return null;
      },
      focusNode: widget.focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
