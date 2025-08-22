import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/input_converter.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

/// A page that allows users to request a password reset by entering email.
///
/// It handles form validation and interacts with the [authControllerProvider]
/// to initiate the forgot password process. On success, it navigates to the
/// OTP verification page.
class ForgotPasswordPage extends HookConsumerWidget {
  /// Creates a [ForgotPasswordPage].
  const ForgotPasswordPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final emailFocusNode = useFocusNode();
    final emailController = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        emailFocusNode.requestFocus();
      });
      return null;
    }, []);

    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (
      final previous,
      final next,
    ) async {
      if (next is AuthForgotPassword) {
        NotificationService.success(
          context: context,
          message: context.t.auth.forgotPasswordSuccess,
        );
        VerifyForgotPasswordOTPRoute(email: emailController.text).go(context);
      }
      if (next is AuthError) {
        NotificationService.error(context: context, message: next.message);
      }
    });
    return Scaffold(
      body: FormBuilder(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Text(
                context.t.auth.forgotPassword,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${context.t.auth.pleaseEnterEmail}.\n',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: context.t.auth.sendCodeThroughMail,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              FormBuilderTextField(
                key: const Key('reset_email_field'),
                name: 'email',
                controller: emailController,
                focusNode: emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  labelText: context.t.auth.email,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                validator: (final value) => InputConverter.validateEmail(
                  value,
                  context,
                ),
                onSubmitted: (final value) async {
                  if (emailFocusNode.hasFocus) {
                    emailFocusNode.unfocus();
                  }
                },
              ),
              const SizedBox.shrink(),
              switch (state) {
                AuthLoading() => const CircularProgressIndicator(),
                _ => SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    key: const Key('send_reset_button'),
                    onPressed: () {
                      if (formKey.currentState!.saveAndValidate()) {
                        final email = emailController.text;
                        ref
                            .read(authControllerProvider.notifier)
                            .forgotPassword(
                              email: email,
                            );
                      }
                    },
                    child: Text(context.t.auth.send),
                  ),
                ),
              },
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () async {
                  const LoginRoute().go(context);
                },
                child: Text(
                  context.t.auth.returnToSignIn,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A page that allows users to reset their password using a reset token.
///
/// It requires a [resetToken] obtained from the forgot password flow.
/// The page handles form validation for the new password and confirmation,
/// and interacts with the [authControllerProvider] to perform the reset.
/// On success, it navigates to the login page.
class ResetPasswordPage extends HookConsumerWidget {
  /// Creates a [ResetPasswordPage].
  ///
  /// [resetToken] is the token required to authorize the password reset.
  const ResetPasswordPage({super.key, required this.resetToken});

  /// The token received via email or other means to reset the password.
  final String resetToken;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('resetToken', resetToken));
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        passwordFocusNode.requestFocus();
      });
      return null;
    }, []);

    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (
      final previous,
      final next,
    ) async {
      if (next is AuthResetPassword) {
        NotificationService.success(
          context: context,
          message: context.t.auth.passwordResetSuccess,
        );
        const LoginRoute().go(context);
      }
      if (next is AuthError && context.mounted) {
        NotificationService.error(context: context, message: next.message);
      }
    });
    return Scaffold(
      body: FormBuilder(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Text(
                context.t.auth.resetPassword.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                context.t.auth.resetPassword.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              AuthTextField(
                controller: passwordController,
                name: 'password',
                focusNode: passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                label: context.t.auth.password,
                validator: (final value) => InputConverter.validatePassword(
                  value,
                  context,
                ),
                onFieldSubmitted: (final value) async {
                  if (passwordFocusNode.hasFocus) {
                    passwordFocusNode.unfocus();
                  }
                  FocusScope.of(context).requestFocus(
                    confirmPasswordFocusNode,
                  );
                },
              ),
              AuthTextField(
                controller: confirmPasswordController,
                name: 'confirm_password',
                label: context.t.auth.confirmPassword,
                focusNode: confirmPasswordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                validator:
                    (
                      final value,
                    ) => InputConverter.validateConfirmPassword(
                      value,
                      context,
                      passwordController.text,
                    ),
                onFieldSubmitted: (final value) async {
                  if (confirmPasswordFocusNode.hasFocus) {
                    confirmPasswordFocusNode.unfocus();
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              switch (state) {
                AuthLoading() => const CircularProgressIndicator(),
                _ => SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () async {
                      if (formKey.currentState!.saveAndValidate()) {
                        await ref
                            .read(authControllerProvider.notifier)
                            .resetPassword(
                              resetToken: resetToken,
                              password: passwordController.text,
                              confirmPassword: confirmPasswordController.text,
                            );
                      }
                    },
                    child: Text(context.t.auth.reset),
                  ),
                ),
              },
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () async {
                  const LoginRoute().go(context);
                },
                child: Text(
                  context.t.auth.returnToSignIn,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
