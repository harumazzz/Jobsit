import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/utils/input_converter.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController _emailController;

  late TextEditingController _passwordController;

  late FocusNode _emailFocusNode;

  late FocusNode _passwordFocusNode;

  late GlobalKey<FormBuilderState> _formKey;

  late bool _savePassword;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _formKey = GlobalKey<FormBuilderState>();
    _savePassword = false;
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      switch (next) {
        case AuthError _:
          toastification.show(
            context: context,
            title: Text(next.message),
            autoCloseDuration: const Duration(seconds: 4),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            showProgressBar: true,
            alignment: Alignment.bottomCenter,
          );
          break;
        case AuthAuthorized _:
          toastification.show(
            context: context,
            title: const Text('Login successfully!'),
            autoCloseDuration: const Duration(seconds: 4),
            style: ToastificationStyle.flatColored,
            type: ToastificationType.success,
            showProgressBar: true,
            alignment: Alignment.bottomCenter,
          );
          const HomeRoute().go(context);
          break;
        default:
          break;
      }
    });
    return Scaffold(
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset('assets/images/icon.png', width: 100.0, height: 100.0),
              ),
              const SizedBox(height: 50.0),
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
                controller: _emailController,
                validator: InputConverter.validateEmail,
                onSubmitted: (_) async {
                  if (_emailFocusNode.hasFocus) {
                    _emailFocusNode.unfocus();
                  }
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              const SizedBox(height: 20.0),
              AuthTextField(
                name: 'password',
                label: 'Password',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                validator: InputConverter.validatePassword,
                onFieldSubmitted: (value) async {
                  if (_passwordFocusNode.hasFocus) {
                    _passwordFocusNode.unfocus();
                  }
                },
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10.0,
                    children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Checkbox.adaptive(
                            value: _savePassword,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _savePassword = value;
                              });
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            activeColor: Theme.of(context).colorScheme.primary,
                            checkColor: Theme.of(context).colorScheme.onPrimary,
                          );
                        },
                      ),
                      const Text('Save password'),
                    ],
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () async {
                      const ForgotPasswordRoute().go(context);
                    },
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              switch (state) {
                AuthLoading() => const CircularProgressIndicator(),
                _ => SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await ref
                            .read(authControllerProvider.notifier)
                            .login(email: _emailController.text, password: _passwordController.text);
                      }
                    },
                    child: const Text('Login'),
                  ),
                ),
              },
              const SizedBox(height: 20.0),
              const Text('Or Sign in with'),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20.0,
                children: [
                  IconButton(
                    icon: SvgPicture.asset('assets/images/icon_google.svg', height: 36.0),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8.0),
                    ),
                    onPressed: () async {
                      // TODO(self): Implement Google login
                    },
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8.0),
                    ),
                    icon: SvgPicture.asset(
                      'assets/images/icon_facebook.svg',
                      height: 36.0,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    onPressed: () async {
                      // TODO(self): Implement Facebook login
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.0,
                children: [
                  const Text(
                    'Don\'t have an Account?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () async {
                      const RegisterRoute().go(context);
                    },
                    child: const Text('Sign Up', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
