import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/input_converter.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneController;
  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;
  late FocusNode _phoneFocusNode;

  late GlobalKey<FormBuilderState> _formKey;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _formKey = GlobalKey<FormBuilderState>();
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      switch (next) {
        case AuthError _:
          ElegantNotification.error(background: const Color(0xFFFCE8DB), description: Text(next.message)).show(context);
          break;
        case AuthRegistered _:
          ElegantNotification.success(
            background: const Color(0xFFDEF2ED),
            description: const Text('Register an account successfully!'),
          ).show(context);
          OtpVerificationRoute(email: _emailController.text).go(context);
          break;
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      appBar: AppBar(title: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20.0),
                FormBuilderTextField(
                  name: 'first_name',
                  keyboardType: TextInputType.name,
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: 'First Name',
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validateName,
                  focusNode: _firstNameFocusNode,
                  onSubmitted: (_) async {
                    if (_firstNameFocusNode.hasFocus) {
                      _firstNameFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(_lastNameFocusNode);
                  },
                ),
                const SizedBox(height: 20.0),
                FormBuilderTextField(
                  name: 'last_name',
                  keyboardType: TextInputType.name,
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: 'Last Name',
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validateName,
                  focusNode: _lastNameFocusNode,
                  onSubmitted: (_) async {
                    if (_lastNameFocusNode.hasFocus) {
                      _lastNameFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                ),
                const SizedBox(height: 20.0),
                RegisterEmailTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  onFieldSubmitted: (value) {
                    if (_emailFocusNode.hasFocus) {
                      _emailFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                const SizedBox(height: 20.0),
                AuthTextField(
                  name: 'password',
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  label: 'Password',
                  validator: InputConverter.validatePassword,
                  onFieldSubmitted: (value) {
                    if (_passwordFocusNode.hasFocus) {
                      _passwordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                  },
                ),
                const SizedBox(height: 20.0),
                AuthTextField(
                  name: 'confirm_password',
                  controller: _confirmPasswordController,
                  validator: InputConverter.validateConfirmPassword,
                  label: 'Confirm Password',
                  focusNode: _confirmPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  onFieldSubmitted: (value) {
                    if (_confirmPasswordFocusNode.hasFocus) {
                      _confirmPasswordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                  },
                ),
                const SizedBox(height: 20.0),
                FormBuilderTextField(
                  name: 'phone',
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    labelText: 'Phone',
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validatePhone,
                  onSubmitted: (_) async {
                    if (_phoneFocusNode.hasFocus) {
                      _phoneFocusNode.unfocus();
                    }
                  },
                ),
                const SizedBox(height: 20.0),
                const Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(text: 'By clicking the \'Register\' button, I agree to the\n'),
                      TextSpan(text: 'Terms of Use', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' of Jobsit.vn'),
                    ],
                  ),
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
                              .register(
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                phone: _phoneController.text,
                              );
                        }
                      },
                      child: const Text('Register'),
                    ),
                  ),
                },
                const SizedBox(height: 20.0),
                const Text('Or Continue With'),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8.0),
                      ),
                      icon: SvgPicture.asset('assets/images/icon_google.svg', height: 36.0),
                      onPressed: () async {
                        // TODO(self): Implement Google registration
                      },
                    ),
                    const SizedBox(width: 20.0),
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
                        // TODO(self): Implement Facebook registration
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(bottom: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an Account?'),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () async => const LoginRoute().go(context),
                child: const Text(' Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
