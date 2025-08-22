import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
class RegisterEmailTextField extends HookConsumerWidget {
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
  Widget build(final BuildContext context, final WidgetRef ref) {
    final emailSubject = useMemoized(PublishSubject<String>.new);
    final isCheckingEmail = useState(false);
    final isEmailAvailable = useState(true);
    final emailErrorText = useState<String?>(null);

    Future<void> checkEmailAvailability(final String email) async {
      try {
        final result = await ref.read(authControllerProvider.notifier).checkEmailExists(email);
        isCheckingEmail.value = false;
        isEmailAvailable.value = !result.toLowerCase().contains('đã sử dụng');
        if (context.mounted) {
          emailErrorText.value = isEmailAvailable.value ? null : context.t.registration.emailExists;
        }
      } catch (e) {
        isCheckingEmail.value = false;
        emailErrorText.value = null;
      }
    }

    Future<void> onEmailChanged() async {
      final email = controller.text;
      if (email.isEmpty || InputConverter.validateEmail(email, context) != null) {
        isCheckingEmail.value = false;
        isEmailAvailable.value = true;
        emailErrorText.value = null;
        return;
      }
      isCheckingEmail.value = true;
      emailErrorText.value = null;
      emailSubject.add(email);
    }

    useEffect(() {
      final subscription = emailSubject.debounceTime(const Duration(milliseconds: 800)).listen(checkEmailAvailability);

      controller.addListener(onEmailChanged);

      return () {
        subscription.cancel();
        emailSubject.close();
        controller.removeListener(onEmailChanged);
      };
    }, []);

    return FormBuilderTextField(
      key: key,
      name: 'email',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelText: context.t.auth.email,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        errorText: emailErrorText.value,
        suffixIcon: isCheckingEmail.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : isEmailAvailable.value &&
                  controller.text.isNotEmpty &&
                  InputConverter.validateEmail(controller.text, context) == null
            ? const Icon(Icons.check_circle_outline, color: Colors.green)
            : null,
      ),
      validator: (final value) {
        final basicValidation = InputConverter.validateEmail(value, context);
        if (basicValidation != null) {
          return basicValidation;
        }
        if (!isEmailAvailable.value) {
          return context.t.registration.emailExists;
        }
        return null;
      },
      focusNode: focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSubmitted: onFieldSubmitted,
    );
  }

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
