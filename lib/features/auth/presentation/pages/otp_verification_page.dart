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

/// A page for users to verify their email using an OTP (One-Time Password).
///
/// This page is typically used after registration. It requires an [email]
/// to which the OTP was sent. It handles OTP input, validation, and
/// resending OTP functionality.
class OtpVerificationPage extends HookConsumerWidget {
  /// Creates an [OtpVerificationPage].
  ///
  /// [email] The email address to which the OTP was sent.
  const OtpVerificationPage({super.key, required this.email});

  /// The email address of the user undergoing OTP verification.
  final String email;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final otpController = useTextEditingController();
    final otpFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        otpFocusNode.requestFocus();
        await ref
            .read(authControllerProvider.notifier)
            .sendMail(
              email: email,
            );
      });
      return null;
    }, []);

    ref.listen<AuthState>(authControllerProvider, (
      final previous,
      final next,
    ) async {
      if (next is AuthVerified) {
        const OtpVerifiedRoute().go(context);
      }
      if (next is AuthSendedMail && context.mounted) {
        NotificationService.success(
          context: context,
          message: context.t.auth.otpSent,
        );
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _Stepper(),
                  const SizedBox(height: 30),
                  Text(context.t.auth.verification),
                  const SizedBox(height: 20),
                  Text(context.t.auth.enterOtp),
                  const SizedBox(height: 30),
                  _OtpField(
                    controller: otpController,
                    focusNode: otpFocusNode,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.t.auth.notHaveTheCode),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          otpFocusNode.unfocus();
                          await ref
                              .read(authControllerProvider.notifier)
                              .resendMail(
                                email: email,
                              );
                        },
                        child: Text(
                          context.t.auth.resend,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      key: const Key('verify_button'),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          otpFocusNode.unfocus();
                          await ref
                              .read(authControllerProvider.notifier)
                              .verifyEmail(
                                otp: otpController.text,
                              );
                        }
                      },
                      child: Text(context.t.auth.verify),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('email', email));
  }
}

/// A specialized text field for OTP input.
///
/// It is configured for numeric input, a maximum length of 6, and
/// includes validation using [InputConverter.validateOtp].
class _OtpField extends StatelessWidget {
  /// Creates an [_OtpField].
  ///
  /// [controller] The [TextEditingController] for the OTP input.
  /// [focusNode] The [FocusNode] for the OTP input field.
  const _OtpField({required this.controller, required this.focusNode});

  /// Controls the text being edited.
  final TextEditingController controller;

  /// Manages the focus of the OTP input field.
  final FocusNode focusNode;

  @override
  Widget build(final BuildContext context) => FormBuilderTextField(
    name: 'otp',
    focusNode: focusNode,
    keyboardType: TextInputType.number,
    maxLength: 6,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      labelText: context.t.auth.enterOtpCode,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      counterText: '',
      errorStyle: const TextStyle(color: Colors.red),
    ),
    controller: controller,
    validator: InputConverter.validateOtp,
    onSubmitted: (_) async {
      focusNode.unfocus();
    },
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<TextEditingController>('controller', controller),
      )
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
  }
}

/// A widget displaying a visual stepper for the OTP verification process.
///
/// It indicates the current step in a multi-step verification flow.
class _Stepper extends StatelessWidget {
  /// Creates a [_Stepper] widget.
  const _Stepper();

  @override
  Widget build(final BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
        radius: 12,
        backgroundColor: Colors.red,
        child: Text('1', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
      Container(width: 40, height: 2, color: Colors.red),
      const CircleAvatar(
        radius: 12,
        backgroundColor: Colors.red,
        child: Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
      Container(width: 40, height: 2, color: Colors.grey),
      const CircleAvatar(
        radius: 12,
        backgroundColor: Colors.grey,
        child: Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    ],
  );
}

/// A page displayed after successful OTP verification.
///
/// Shows a success message and image, then automatically navigates
/// to the home route after a short delay.
class OtpVerifiedPage extends StatelessWidget {
  /// Creates an [OtpVerifiedPage].
  const OtpVerifiedPage({super.key});

  @override
  Widget build(final BuildContext context) {
    NotificationService.success(
      context: context,
      message: context.t.auth.accountVerifiedSuccess,
    );
    useDebounced(
      () async => const HomeRoute().go(context),
      const Duration(seconds: 5),
    );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Image.asset('assets/images/checked.png', width: 85, height: 85),
            Text(
              context.t.auth.accountVerifiedSuccess,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A page for OTP verification specifically for the forgot password flow.
///
/// Requires the [email] address to which the OTP was sent. It handles
/// OTP input, validation, and resending OTP functionality related to
/// password reset.
class ForgotPasswordOTP extends HookConsumerWidget {
  /// Creates a [ForgotPasswordOTP] page.
  ///
  /// [email] The email address associated with the forgot password request.
  const ForgotPasswordOTP({super.key, required this.email});

  /// The email address for which the OTP was requested.
  final String email;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final otpController = useTextEditingController();
    final otpFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        otpFocusNode.requestFocus();
        await ref
            .read(authControllerProvider.notifier)
            .sendMail(
              email: email,
            );
      });
      return null;
    }, []);

    ref.listen<AuthState>(authControllerProvider, (
      final previous,
      final next,
    ) async {
      if (next is AuthVerified) {
        const OtpVerifiedRoute().go(context);
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _Stepper(),
                  const SizedBox(height: 30),
                  Text(context.t.auth.verification),
                  const SizedBox(height: 20),
                  Text(context.t.auth.enterOtp),
                  const SizedBox(height: 30),
                  _OtpField(
                    controller: otpController,
                    focusNode: otpFocusNode,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.t.auth.notHaveTheCode),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          otpFocusNode.unfocus();
                          await ref
                              .read(authControllerProvider.notifier)
                              .forgotPassword(
                                email: email,
                              );
                        },
                        child: Text(
                          context.t.auth.resend,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          otpFocusNode.unfocus();
                          await ref
                              .read(authControllerProvider.notifier)
                              .verifyOtp(
                                otp: otpController.text,
                              );
                        }
                      },
                      child: Text(context.t.auth.verify),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('email', email));
  }
}
