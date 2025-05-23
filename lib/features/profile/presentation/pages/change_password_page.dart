import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/input_converter.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// A page that allows the currently authenticated user to change their password
///
/// It provides fields for the current password, new password, and confirmation
/// of the new password. It uses [FormBuilder] for form management and
/// validation.
class ChangePasswordPage extends HookWidget {
  /// Creates a [ChangePasswordPage].
  const ChangePasswordPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final isSubmitting = useState(false);
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final currentPasswordFocusNode = useFocusNode();
    final newPasswordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();
    final validateConfirmPassword = useCallback((final String? value) {
      if (value != newPasswordController.text) {
        return context.t.validation.format.passwordMismatch;
      }
      return null;
    }, [newPasswordController.text]);
    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFefeff0),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.t.auth.changePassword,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily:
                        GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                        ).fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                FormBuilderTextField(
                  name: 'current_password',
                  controller: currentPasswordController,
                  focusNode: currentPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: context.t.auth.password,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator:
                      (final value) => InputConverter.validatePassword(
                        value,
                        context,
                      ),
                  onSubmitted: (_) async {
                    if (currentPasswordFocusNode.hasFocus) {
                      currentPasswordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(newPasswordFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'new_password',
                  controller: newPasswordController,
                  focusNode: newPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: context.t.auth.newPassword,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator:
                      (final value) => InputConverter.validatePassword(
                        value,
                        context,
                      ),
                  onSubmitted: (_) async {
                    if (newPasswordFocusNode.hasFocus) {
                      newPasswordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(
                      confirmPasswordFocusNode,
                    );
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'confirm_new_password',
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: context.t.auth.confirmNewPassword,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) {
                    final passwordValidation = InputConverter.validatePassword(
                      value,
                      context,
                    );
                    if (passwordValidation != null) {
                      return passwordValidation;
                    }
                    return validateConfirmPassword(value);
                  },
                  onSubmitted: (_) async {
                    if (confirmPasswordFocusNode.hasFocus) {
                      confirmPasswordFocusNode.unfocus();
                    }
                  },
                ),
                const SizedBox(height: 40),
                Consumer(
                  builder:
                      (final context, final ref, final child) => _ChangeButton(
                        formKey: formKey,
                        currentPasswordController: currentPasswordController,
                        newPasswordController: newPasswordController,
                        confirmPasswordController: confirmPasswordController,
                        currentPasswordFocusNode: currentPasswordFocusNode,
                        newPasswordFocusNode: newPasswordFocusNode,
                        confirmPasswordFocusNode: confirmPasswordFocusNode,
                        ref: ref,
                        isSubmitting: isSubmitting,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A private button widget used within the [ChangePasswordPage] to submit
/// the password change request.
class _ChangeButton extends StatelessWidget {
  /// Creates a [_ChangeButton].
  ///
  /// All parameters are required and are used to manage form state,
  /// focus, and interaction with the authentication provider.
  const _ChangeButton({
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.currentPasswordFocusNode,
    required this.newPasswordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.ref,
    required this.isSubmitting,
  });

  /// The global key for the [FormBuilder] state.
  final GlobalKey<FormBuilderState> formKey;

  /// Controller for the current password text field.
  final TextEditingController currentPasswordController;

  /// Controller for the new password text field.
  final TextEditingController newPasswordController;

  /// Controller for the confirm new password text field.
  final TextEditingController confirmPasswordController;

  /// Focus node for the current password text field.
  final FocusNode currentPasswordFocusNode;

  /// Focus node for the new password text field.
  final FocusNode newPasswordFocusNode;

  /// Focus node for the confirm new password text field.
  final FocusNode confirmPasswordFocusNode;

  /// Riverpod widget reference for accessing providers.
  final WidgetRef ref;

  /// A [ValueNotifier] to track if the form is currently being submitted,
  /// to prevent multiple submissions.
  final ValueNotifier<bool> isSubmitting;

  @override
  Widget build(final BuildContext context) => CustomButton(
    onPressed: () async {
      if (isSubmitting.value) {
        return;
      }
      if (currentPasswordFocusNode.hasFocus) {
        currentPasswordFocusNode.unfocus();
      }
      if (newPasswordFocusNode.hasFocus) {
        newPasswordFocusNode.unfocus();
      }
      if (confirmPasswordFocusNode.hasFocus) {
        confirmPasswordFocusNode.unfocus();
      }
      if (formKey.currentState!.validate()) {
        await ref
            .read(authControllerProvider.notifier)
            .changePassword(
              oldPassword: currentPasswordController.text,
              newPassword: newPasswordController.text,
              confirmPassword: confirmPasswordController.text,
            );
        if (context.mounted) {
          NotificationService.success(
            context: context,
            message: context.t.password.changeSuccess,
          );
          context.pop();
        }
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(context.t.password.change),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<GlobalKey<FormBuilderState>>('formKey', formKey),
      )
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'currentPasswordController',
          currentPasswordController,
        ),
      )
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'newPasswordController',
          newPasswordController,
        ),
      )
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'confirmPasswordController',
          confirmPasswordController,
        ),
      )
      ..add(
        DiagnosticsProperty<FocusNode>(
          'currentPasswordFocusNode',
          currentPasswordFocusNode,
        ),
      )
      ..add(
        DiagnosticsProperty<FocusNode>(
          'newPasswordFocusNode',
          newPasswordFocusNode,
        ),
      )
      ..add(
        DiagnosticsProperty<FocusNode>(
          'confirmPasswordFocusNode',
          confirmPasswordFocusNode,
        ),
      )
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(
        DiagnosticsProperty<ValueNotifier<bool>>('isSubmitting', isSubmitting),
      );
  }
}
