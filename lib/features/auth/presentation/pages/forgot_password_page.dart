import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/input_converter.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late GlobalKey<FormBuilderState> _formKey;

  late FocusNode _emailFocusNode;

  late TextEditingController _emailController;

  @override
  void initState() {
    _formKey = GlobalKey<FormBuilderState>();
    _emailFocusNode = FocusNode();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next is AuthForgotPassword) {
        NotificationService.success(context: context, message: context.t.auth.forgotPasswordSuccess);
        VerifyForgotPasswordOTPRoute(email: _emailController.text).go(context);
      }
      if (next is AuthError) {
        NotificationService.error(context: context, message: next.message);
      }
    });
    return Scaffold(
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20.0,
            children: [
              Text(context.t.auth.forgotPassword, style: Theme.of(context).textTheme.headlineLarge),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${context.t.auth.pleaseEnterEmail}.\n',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    TextSpan(
                      text: context.t.auth.sendCodeThroughMail,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              FormBuilderTextField(
                name: 'email',
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  labelText: context.t.auth.email,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
                validator: (value) => InputConverter.validateEmail(value, context),
                onSubmitted: (value) {
                  if (_emailFocusNode.hasFocus) {
                    _emailFocusNode.unfocus();
                  }
                },
              ),
              const SizedBox.shrink(),
              switch (state) {
                AuthLoading() => const CircularProgressIndicator(),
                _ => SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final email = _emailController.text;
                        ref.read(authControllerProvider.notifier).forgotPassword(email: email);
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.resetToken});

  final String resetToken;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('resetToken', resetToken));
  }
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  late GlobalKey<FormBuilderState> _formKey;

  late TextEditingController _passwordController;

  late TextEditingController _confirmPasswordController;

  late FocusNode _passwordFocusNode;

  late FocusNode _confirmPasswordFocusNode;

  @override
  void initState() {
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormBuilderState>();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _passwordFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next is AuthResetPassword) {
        NotificationService.success(
          context: context,
          message: 'Password reset successfully. Please login with your new password.',
        );
        const LoginRoute().go(context);
      }
      if (next is AuthError && context.mounted) {
        NotificationService.error(context: context, message: next.message);
      }
    });
    return Scaffold(
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20.0,
            children: [
              Text('Reset Password', style: Theme.of(context).textTheme.headlineLarge),
              Text(
                'Please enter new password',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              AuthTextField(
                controller: _passwordController,
                name: 'password',
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                label: context.t.auth.password,
                validator: (value) => InputConverter.validatePassword(value, context),
                onFieldSubmitted: (value) async {
                  if (_passwordFocusNode.hasFocus) {
                    _passwordFocusNode.unfocus();
                  }
                  FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                },
              ),
              AuthTextField(
                controller: _confirmPasswordController,
                name: 'confirm_password',
                label: context.t.auth.confirmPassword,
                focusNode: _confirmPasswordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) => InputConverter.validateConfirmPassword(value, context, _passwordController.text),
                onFieldSubmitted: (value) async {
                  if (_confirmPasswordFocusNode.hasFocus) {
                    _confirmPasswordFocusNode.unfocus();
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
                      if (_formKey.currentState!.saveAndValidate()) {
                        await ref
                            .read(authControllerProvider.notifier)
                            .resetPassword(
                              resetToken: widget.resetToken,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
