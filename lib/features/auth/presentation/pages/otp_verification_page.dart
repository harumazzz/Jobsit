import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/input_converter.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('email', email));
  }
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  late TextEditingController _otpController;

  late FocusNode _otpFocusNode;

  late GlobalKey<FormBuilderState> _formKey;

  @override
  void initState() {
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    _formKey = GlobalKey<FormBuilderState>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _otpFocusNode.requestFocus();
      await ref.read(authControllerProvider.notifier).sendMail(email: widget.email);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next is AuthVerified) {
        const OtpVerifiedRoute().go(context);
      }
      if (next is AuthSendedMail && context.mounted) {
        NotificationService.success(context: context, message: context.t.auth.otpSent);
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _Stepper(),
                  const SizedBox(height: 30.0),
                  Text(context.t.auth.verification),
                  const SizedBox(height: 20.0),
                  Text(context.t.auth.enterOtp),
                  const SizedBox(height: 30.0),
                  _OtpField(controller: _otpController, focusNode: _otpFocusNode),
                  const SizedBox(height: 20.0),
                  Row(
                    spacing: 4.0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.t.auth.notHaveTheCode),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          _otpFocusNode.unfocus();
                          await ref.read(authControllerProvider.notifier).resendMail(email: widget.email);
                        },
                        child: Text(context.t.auth.resend, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _otpFocusNode.unfocus();
                          await ref.read(authControllerProvider.notifier).verifyEmail(otp: _otpController.text);
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
}

class _OtpField extends StatelessWidget {
  const _OtpField({required this.controller, required this.focusNode});

  final TextEditingController controller;

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'otp',
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        labelText: context.t.auth.enterOtpCode,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        counterText: '',
        errorStyle: const TextStyle(color: Colors.red),
      ),
      controller: controller,
      validator: InputConverter.validateOtp,
      onSubmitted: (_) async {
        focusNode.unfocus();
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper();

  @override
  Widget build(BuildContext context) {
    return Row(
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
}

class OtpVerifiedPage extends StatelessWidget {
  const OtpVerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService.success(context: context, message: 'Account verified successfully');
    useDebounced(() async => const HomeRoute().go(context), const Duration(seconds: 5));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12.0,
          children: [
            Image.asset('assets/images/checked.png', width: 85, height: 85),
            Text(
              context.t.auth.accountVerifiedSuccess,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordOTP extends ConsumerStatefulWidget {
  const ForgotPasswordOTP({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ForgotPasswordOTP> createState() => _ForgotPasswordOTPState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('email', email));
  }
}

class _ForgotPasswordOTPState extends ConsumerState<ForgotPasswordOTP> {
  late TextEditingController _otpController;

  late FocusNode _otpFocusNode;

  late GlobalKey<FormBuilderState> _formKey;

  @override
  void initState() {
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    _formKey = GlobalKey<FormBuilderState>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _otpFocusNode.requestFocus();
      await ref.read(authControllerProvider.notifier).sendMail(email: widget.email);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next is AuthVerified) {
        const OtpVerifiedRoute().go(context);
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _Stepper(),
                  const SizedBox(height: 30.0),
                  Text(context.t.auth.verification),
                  const SizedBox(height: 20.0),
                  Text(context.t.auth.enterOtp),
                  const SizedBox(height: 30.0),
                  _OtpField(controller: _otpController, focusNode: _otpFocusNode),
                  const SizedBox(height: 20.0),
                  Row(
                    spacing: 4.0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.t.auth.notHaveTheCode),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          _otpFocusNode.unfocus();
                          await ref.read(authControllerProvider.notifier).forgotPassword(email: widget.email);
                        },
                        child: Text(context.t.auth.resend, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _otpFocusNode.unfocus();
                          await ref.read(authControllerProvider.notifier).verifyOtp(otp: _otpController.text);
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
}
