import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/input_converter.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordPage extends HookWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final currentPasswordFocusNode = useFocusNode();
    final newPasswordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();
    final validateConfirmPassword = useCallback(
      (String? value) {
        if (value != newPasswordController.text) {
          return 'Passwords do not match';
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
                  'Change Password',
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: 'Password',
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validatePassword,
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: 'New Password',
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validatePassword,
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: 'Confirm New Password',
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) {
                    final passwordValidation = InputConverter.validatePassword(value);
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
                    return CustomButton(
                      onPressed: () async {
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
                            ElegantNotification.success(
                              background: const Color(0xFFDEF2ED),
                              description: const Text('Password changed successfully!'),
                            ).show(context);
                            context.pop();
                          }
                        }
                      },
                      child: const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Change')),
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
