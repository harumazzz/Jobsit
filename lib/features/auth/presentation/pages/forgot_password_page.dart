import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:elegant_notification/elegant_notification.dart';

import '../../../../core/utils/input_converter.dart';
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
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next is AuthForgotPassword) {
        ElegantNotification.success(
          background: const Color(0xFFDEF2ED),
          description: const Text('Verification code sent to your email. Please check your inbox.'),
        ).show(context);
        // TODO(self): Navigate to OTP verification page for reset password
      }
      if (next is AuthError) {
        ElegantNotification.error(background: const Color(0xFFFCE8DB), description: Text(next.message)).show(context);
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20.0,
            children: [
              Text('Forgot Password', style: Theme.of(context).textTheme.headlineLarge),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Please enter your Registered Email.\n',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    TextSpan(
                      text: 'We will send a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              FormBuilderTextField(
                name: 'email',
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  labelText: 'Email',
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
                validator: InputConverter.validateEmail,
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
                        final email = _formKey.currentState!.value['email'] as String;
                        ref.read(authControllerProvider.notifier).forgotPassword(email: email);
                      }
                    },
                    child: const Text('Send'),
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
                child: const Text('Return to Sign In', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
        ElegantNotification.success(
          background: const Color(0xFFDEF2ED),
          description: const Text('Password reset successfully. Please login with your new password.'),
        ).show(context);
        const LoginRoute().go(context);
      }
      if (next is AuthError) {
        ElegantNotification.error(background: const Color(0xFFFCE8DB), description: Text(next.message)).show(context);
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
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
                label: 'Password',
                validator: InputConverter.validatePassword,
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
                label: 'Confirm Password',
                focusNode: _confirmPasswordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  (value) {
                    if (value != _passwordController.text) {
                      return 'Confirm Password does not match';
                    }
                    return null;
                  },
                ]),
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
                    child: const Text('Reset'),
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
                child: const Text('Return to Sign In', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
