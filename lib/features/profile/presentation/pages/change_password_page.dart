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

class ChangePasswordPage extends HookWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final isSubmitting = useState(false);
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final currentPasswordFocusNode = useFocusNode();
    final newPasswordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();
    final validateConfirmPassword = useCallback(
      (String? value) {
        if (value != newPasswordController.text) {
          return context.t.validation.format.passwordMismatch;
        }
        return null;
      },
      () {
        return [newPasswordController.text];
      }(),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      appBar: AppBar(backgroundColor: const Color(0xFFefeff0), foregroundColor: Colors.black, elevation: 0.0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.t.auth.changePassword,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: GoogleFonts.workSans(fontWeight: FontWeight.bold).fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30.0),
                FormBuilderTextField(
                  name: 'current_password',
                  controller: currentPasswordController,
                  focusNode: currentPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: context.t.auth.password,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) => InputConverter.validatePassword(value, context),
                  onSubmitted: (_) async {
                    if (currentPasswordFocusNode.hasFocus) {
                      currentPasswordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(newPasswordFocusNode);
                  },
                ),
                const SizedBox(height: 20.0),
                FormBuilderTextField(
                  name: 'new_password',
                  controller: newPasswordController,
                  focusNode: newPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: context.t.auth.newPassword,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) => InputConverter.validatePassword(value, context),
                  onSubmitted: (_) async {
                    if (newPasswordFocusNode.hasFocus) {
                      newPasswordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                  },
                ),
                const SizedBox(height: 20.0),
                FormBuilderTextField(
                  name: 'confirm_new_password',
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: context.t.auth.confirmNewPassword,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) {
                    final passwordValidation = InputConverter.validatePassword(value, context);
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
                const SizedBox(height: 40.0),
                Consumer(
                  builder: (context, ref, child) {
                    return _ChangeButton(
                      formKey: formKey,
                      currentPasswordController: currentPasswordController,
                      newPasswordController: newPasswordController,
                      confirmPasswordController: confirmPasswordController,
                      currentPasswordFocusNode: currentPasswordFocusNode,
                      newPasswordFocusNode: newPasswordFocusNode,
                      confirmPasswordFocusNode: confirmPasswordFocusNode,
                      ref: ref,
                      isSubmitting: isSubmitting,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
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

  final GlobalKey<FormBuilderState> formKey;

  final TextEditingController currentPasswordController;

  final TextEditingController newPasswordController;

  final TextEditingController confirmPasswordController;

  final FocusNode currentPasswordFocusNode;

  final FocusNode newPasswordFocusNode;

  final FocusNode confirmPasswordFocusNode;

  final WidgetRef ref;

  final ValueNotifier<bool> isSubmitting;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
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
            NotificationService.success(context: context, message: context.t.password.changeSuccess);
            context.pop();
          }
        }
      },
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(context.t.password.change)),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey<FormBuilderState>>('formKey', formKey));
    properties.add(DiagnosticsProperty<TextEditingController>('currentPasswordController', currentPasswordController));
    properties.add(DiagnosticsProperty<TextEditingController>('newPasswordController', newPasswordController));
    properties.add(DiagnosticsProperty<TextEditingController>('confirmPasswordController', confirmPasswordController));
    properties.add(DiagnosticsProperty<FocusNode>('currentPasswordFocusNode', currentPasswordFocusNode));
    properties.add(DiagnosticsProperty<FocusNode>('newPasswordFocusNode', newPasswordFocusNode));
    properties.add(DiagnosticsProperty<FocusNode>('confirmPasswordFocusNode', confirmPasswordFocusNode));
    properties.add(DiagnosticsProperty<WidgetRef>('ref', ref));
    properties.add(DiagnosticsProperty<ValueNotifier<bool>>('isSubmitting', isSubmitting));
  }
}
