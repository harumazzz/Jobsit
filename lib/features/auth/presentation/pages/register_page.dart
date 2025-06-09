import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/input_converter.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

/// The registration page for new users.
///
/// Allows users to create a new account by providing their first name,
/// last name, email, password, and phone number. It includes form validation
/// and navigation to OTP verification upon successful registration.
/// Also provides options for social registration.
class RegisterPage extends HookConsumerWidget {
  /// Creates a [RegisterPage].
  const RegisterPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final phoneController = useTextEditingController();
    final firstNameFocusNode = useFocusNode();
    final lastNameFocusNode = useFocusNode();
    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();
    final phoneFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (
      final previous,
      final next,
    ) async {
      switch (next) {
        case AuthError _:
          NotificationService.error(
            context: context,
            message: context.t.registration.emailExists,
          );
          break;
        case AuthRegistered _:
          NotificationService.success(
            context: context,
            message: context.t.registration.success,
          );
          OtpVerificationRoute(email: emailController.text).go(context);
          break;
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      appBar: AppBar(
        title: Text(
          context.t.auth.register,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFefeff0),
      ),
      body: FormBuilder(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                FormBuilderTextField(
                  key: const Key('first_name_field'),
                  name: 'first_name',
                  keyboardType: TextInputType.name,
                  controller: firstNameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: context.t.auth.firstName,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validateFirstName(
                    value,
                    context,
                  ),
                  focusNode: firstNameFocusNode,
                  onSubmitted: (_) async {
                    if (firstNameFocusNode.hasFocus) {
                      firstNameFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(lastNameFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  key: const Key('last_name_field'),
                  name: 'last_name',
                  keyboardType: TextInputType.name,
                  controller: lastNameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: context.t.auth.lastName,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validateLastName(
                    value,
                    context,
                  ),
                  focusNode: lastNameFocusNode,
                  onSubmitted: (_) async {
                    if (lastNameFocusNode.hasFocus) {
                      lastNameFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(emailFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                RegisterEmailTextField(
                  key: const Key('email_field'),
                  controller: emailController,
                  focusNode: emailFocusNode,
                  onFieldSubmitted: (final value) {
                    if (emailFocusNode.hasFocus) {
                      emailFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(passwordFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  key: const Key('password_field'),
                  name: 'password',
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: passwordFocusNode,
                  controller: passwordController,
                  label: context.t.auth.password,
                  validator: (final value) => InputConverter.validatePassword(
                    value,
                    context,
                  ),
                  onFieldSubmitted: (final value) {
                    if (passwordFocusNode.hasFocus) {
                      passwordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(
                      confirmPasswordFocusNode,
                    );
                  },
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  key: const Key('confirm_password_field'),
                  name: 'confirm_password',
                  controller: confirmPasswordController,
                  validator:
                      (
                        final value,
                      ) => InputConverter.validateConfirmPassword(
                        value,
                        context,
                        passwordController.text,
                      ),
                  label: context.t.auth.confirmPassword,
                  focusNode: confirmPasswordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  onFieldSubmitted: (final value) {
                    if (confirmPasswordFocusNode.hasFocus) {
                      confirmPasswordFocusNode.unfocus();
                    }
                    FocusScope.of(context).requestFocus(phoneFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  key: const Key('phone_field'),
                  name: 'phone',
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: context.t.auth.phone,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validatePhone(
                    value,
                    context,
                  ),
                  onSubmitted: (_) async {
                    if (phoneFocusNode.hasFocus) {
                      phoneFocusNode.unfocus();
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(text: context.t.auth.termsAndConditions.prefix),
                      TextSpan(
                        text: context.t.auth.termsAndConditions.termsOfUse,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: context.t.auth.termsAndConditions.and),
                      TextSpan(
                        text: context.t.auth.termsAndConditions.privacyPolicy,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: context.t.auth.termsAndConditions.suffix),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                switch (state) {
                  AuthLoading() => const CircularProgressIndicator(),
                  _ => SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      key: const Key('register_button'),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await ref
                              .read(authControllerProvider.notifier)
                              .register(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                phone: phoneController.text,
                              );
                        }
                      },
                      child: Text(context.t.auth.register),
                    ),
                  ),
                },
                const SizedBox(height: 20),
                Text(context.t.auth.orContinueWith),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                      icon: SvgPicture.asset('assets/images/icon_google.svg', height: 36),
                      onPressed: () async {
                        // TODO(self): Implement Google registration
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                      icon: SvgPicture.asset(
                        'assets/images/icon_facebook.svg',
                        height: 36,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
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
          margin: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.t.auth.alreadyHaveAccount),
              InkWell(
                key: const Key('signin_link'),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () async => const LoginRoute().go(context),
                child: Text(
                  ' ${context.t.auth.login}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
