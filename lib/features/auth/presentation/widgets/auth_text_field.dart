import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/utils/input_converter.dart';
import '../../../../i18n/strings.g.dart';
import '../providers/auth_provider.dart';

/// A reusable text field widget for authentication forms, for passwords.
///
/// It uses [FormBuilderTextField] and is pre-configured for obscured text.
class AuthTextField extends StatelessWidget {
  /// Creates an [AuthTextField].
  ///
  /// [controller] Manages the text being edited.
  /// [label] The text to display as the label for the field.
  /// [focusNode] Manages the focus of the field.
  /// [name] The name of the field in the form.
  /// [keyboardType] The type of keyboard to use for editing the text.
  /// [validator] An optional function that validates the input.
  /// [onFieldSubmitted] An optional callback when the user submits the field.
  /// [autovalidateMode] Mode to enable auto-validation.
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.focusNode,
    required this.name,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    this.autovalidateMode,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The autovalidation mode for the text field.
  final AutovalidateMode? autovalidateMode;

  /// The label text for the text field.
  final String label;

  /// The name of the field, used by FormBuilder.
  final String name;

  /// The focus node for the text field.
  final FocusNode focusNode;

  /// The type of keyboard to use for input.
  final TextInputType? keyboardType;

  /// A function that validates the input.
  ///
  /// Returns an error string to display if the input is invalid, or null
  /// otherwise.
  final String? Function(String? value)? validator;

  /// Called when the user indicates that they are done editing the text in the
  /// field.
  final void Function(String? value)? onFieldSubmitted;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<TextEditingController>('controller', controller),
      )
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(DiagnosticsProperty<TextInputType?>('keyboardType', keyboardType))
      ..add(
        ObjectFlagProperty<String? Function(String? value)?>.has(
          'validator',
          validator,
        ),
      )
      ..add(
        ObjectFlagProperty<void Function(String value)?>.has(
          'onFieldSubmitted',
          onFieldSubmitted,
        ),
      )
      ..add(
        EnumProperty<AutovalidateMode?>(
          'autovalidateMode',
          autovalidateMode,
        ),
      )
      ..add(StringProperty('name', name));
  }

  @override
  Widget build(final BuildContext context) => FormBuilderTextField(
    name: name,
    focusNode: focusNode,
    keyboardType: keyboardType,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    ),
    controller: controller,
    obscureText: true,
    autovalidateMode: autovalidateMode,
    validator: validator,
    onSubmitted: onFieldSubmitted,
  );
}

/// A specialized email text field for registration forms.
///
/// It includes real-time email availability checking with a debounce mechanism
/// to avoid excessive API calls. It displays a loading indicator during checks
/// and a success icon if the email is valid and available.
class RegisterEmailTextField extends ConsumerStatefulWidget {
  /// Creates a [RegisterEmailTextField].
  ///
  /// [controller] Manages the text being edited.
  /// [focusNode] Manages the focus of the field.
  /// [onFieldSubmitted] An optional callback when the user submits the field.
  const RegisterEmailTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onFieldSubmitted,
  });

  /// The controller for the email input field.
  final TextEditingController controller;

  /// The focus node for the email input field.
  final FocusNode focusNode;

  /// Called when the user indicates that they are done editing the text in the
  /// field.
  final void Function(String? value)? onFieldSubmitted;

  @override
  // ignore: lines_longer_than_80_chars
  ConsumerState<RegisterEmailTextField> createState() => _RegisterEmailTextFieldState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'controller',
          controller,
        ),
      )
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(
        ObjectFlagProperty<void Function(String value)?>.has(
          'onFieldSubmitted',
          onFieldSubmitted,
        ),
      );
  }
}

// ignore: lines_longer_than_80_chars
class _RegisterEmailTextFieldState extends ConsumerState<RegisterEmailTextField> {
  late PublishSubject<String> _emailSubject;
  bool _isCheckingEmail = false;
  bool _isEmailAvailable = true;
  String? _emailErrorText;

  @override
  void initState() {
    super.initState();
    _emailSubject = PublishSubject<String>();
    _emailSubject
        .debounceTime(
          const Duration(milliseconds: 800),
        )
        .listen(_checkEmailAvailability);
    widget.controller.addListener(_onEmailChanged);
  }

  Future<void> _onEmailChanged() async {
    final email = widget.controller.text;
    if (email.isEmpty || InputConverter.validateEmail(email, context) != null) {
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

  Future<void> _checkEmailAvailability(final String email) async {
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .checkEmailExists(
            email,
          );
      setState(() {
        _isCheckingEmail = false;
        _isEmailAvailable = !result.toLowerCase().contains('đã sử dụng');
        // ignore: lines_longer_than_80_chars
        _emailErrorText = _isEmailAvailable ? null : context.t.registration.emailExists;
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
  Widget build(final BuildContext context) => FormBuilderTextField(
    key: widget.key,
    name: 'email',
    controller: widget.controller,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      labelText: context.t.auth.email,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      errorText: _emailErrorText,
      suffixIcon: _isCheckingEmail
          ? const SizedBox(
              width: 20,
              height: 20,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : _isEmailAvailable &&
                widget.controller.text.isNotEmpty &&
                // ignore: lines_longer_than_80_chars
                InputConverter.validateEmail(widget.controller.text, context) == null
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : null,
    ),
    validator: (final value) {
      final basicValidation = InputConverter.validateEmail(value, context);
      if (basicValidation != null) {
        return basicValidation;
      }
      if (!_isEmailAvailable) {
        return context.t.registration.emailExists;
      }
      return null;
    },
    focusNode: widget.focusNode,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    onSubmitted: widget.onFieldSubmitted,
  );
}
