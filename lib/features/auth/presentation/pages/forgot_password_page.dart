import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  late TextEditingController _emailController;

  late FocusNode _emailFocusNode;

  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _emailController = TextEditingController();
    _emailFocusNode = FocusNode();
    _formKey = GlobalKey<FormState>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next is AuthForgotPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email. Please check your inbox.'),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // TODO(self): Navigate to OTP verification page for reset password
      }
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });
    return Scaffold(
      body: Form(
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
              TextFormField(
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  labelText: 'Email',
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
                controller: _emailController,
                validator: InputConverter.validateEmail,
                onFieldSubmitted: (value) async {
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await ref.read(authControllerProvider.notifier).forgotPassword(email: _emailController.text);
                      }
                    },
                    child: const Text('Send'),
                  ),
                ),
              },
              GestureDetector(
                onTap: () async {
                  context.goNamed(AppRouter.loginName);
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
  late TextEditingController _passwordController;

  late TextEditingController _confirmPasswordController;

  late FocusNode _passwordFocusNode;

  late FocusNode _confirmPasswordFocusNode;

  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _formKey = GlobalKey<FormState>();
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
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next is AuthResetPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully. Please login with your new password.'),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.goNamed(AppRouter.loginName);
      }
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });
    return Scaffold(
      body: Form(
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
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                validator: InputConverter.validatePassword,
                label: 'Password',
                onFieldSubmitted: (value) async {
                  if (_passwordFocusNode.hasFocus) {
                    _passwordFocusNode.unfocus();
                  }
                  FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                },
              ),
              AuthTextField(
                focusNode: _confirmPasswordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                controller: _confirmPasswordController,
                validator: (value) {
                  final result = InputConverter.validatePassword(value);
                  if (result != null) {
                    return result;
                  }
                  if (value != _passwordController.text) {
                    return 'Confirm Password does not match';
                  }
                  return null;
                },
                label: 'Confirm Password',
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
                      if (_formKey.currentState!.validate()) {
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
              GestureDetector(
                onTap: () async {
                  context.goNamed(AppRouter.loginName);
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
