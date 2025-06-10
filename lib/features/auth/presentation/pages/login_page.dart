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

/// The login page for the application.
///
/// Allows users to sign in using their email and password, or navigate to
/// registration and password recovery. It also provides options for social
/// logins (Google, Facebook - currently placeholders).
class LoginPage extends HookConsumerWidget {
  /// Creates a [LoginPage].
  const LoginPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final savePassword = useState(false);

    final state = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (
      final previous,
      final next,
    ) async {
      switch (next) {
        case AuthError _:
          NotificationService.error(
            context: context,
            message: context.t.login.fail,
          );
          break;
        case AuthAuthorized _:
          NotificationService.success(
            context: context,
            message: context.t.login.success,
          );
          const HomeRoute().go(context);
          break;
        default:
          break;
      }
    });

    return Scaffold(
      body: FormBuilder(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/images/icon.png', width: 100, height: 100),
                ),
                const SizedBox(height: 50),
                FormBuilderTextField(
                  key: const Key('email_field'),
                  name: 'email',
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
                  controller: emailController,
                  validator: (final value) => InputConverter.validateEmail(
                    value,
                    context,
                  ),
                  onSubmitted: (_) async {
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
                  label: context.t.auth.password,
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (final value) => InputConverter.validatePassword(
                    value,
                    context,
                  ),
                  onFieldSubmitted: (final value) async {
                    if (passwordFocusNode.hasFocus) {
                      passwordFocusNode.unfocus();
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        Checkbox.adaptive(
                          value: savePassword.value,
                          onChanged: (final value) {
                            if (value == null) {
                              return;
                            }
                            savePassword.value = value;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: Theme.of(context).colorScheme.primary,
                          checkColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        Text(context.t.auth.savePassword),
                      ],
                    ),
                    TextButton(
                      key: const Key('forgot_password_button'),
                      onPressed: () async {
                        const ForgotPasswordRoute().go(context);
                      },
                      child: Text(context.t.auth.forgotPassword),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                switch (state) {
                  AuthLoading() => const CircularProgressIndicator(),
                  _ => SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      key: const Key('login_button'),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await ref
                              .read(authControllerProvider.notifier)
                              .login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                        }
                      },
                      child: Text(context.t.auth.login),
                    ),
                  ),
                },
                const SizedBox(height: 20),
                Text(context.t.auth.orSignInWith),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset('assets/images/icon_google.svg', height: 36),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () async {
                        // TODO(self): Implement Google login
                      },
                    ),
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
                        // TODO(self): Implement Facebook login
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
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
            spacing: 4,
            children: [
              Text(
                context.t.auth.notHaveAccount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              TextButton(
                key: const Key('signup_link'),
                onPressed: () async {
                  const RegisterRoute().go(context);
                },
                child: Text(
                  context.t.auth.register,
                  style: const TextStyle(
                    fontSize: 14,
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
