import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/input_converter.dart';
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

  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    _formKey = GlobalKey<FormState>();
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
        context.goNamed('otp_verified');
      }
      if (next is AuthSendedMail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email. Please check your inbox.'),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Stepper(),
                const SizedBox(height: 30.0),
                const Text('VERIFICATION'),
                const SizedBox(height: 20.0),
                const Text('Enter the OTP code that we send you via SMS'),
                const SizedBox(height: 30.0),
                _OtpField(controller: _otpController, focusNode: _otpFocusNode),
                const SizedBox(height: 20.0),
                Row(
                  spacing: 4.0,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Didn\'t receive the code?'),
                    GestureDetector(
                      onTap: () async {
                        _otpFocusNode.unfocus();
                        await ref.read(authControllerProvider.notifier).resendMail(email: widget.email);
                      },
                      child: const Text('Resend', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _otpFocusNode.unfocus();
                        await ref.read(authControllerProvider.notifier).verifyOtp(otp: _otpController.text);
                      }
                    },
                    child: const Text('Verify'),
                  ),
                ),
              ],
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
    return TextFormField(
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        labelText: 'Enter OTP code',
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        counterText: '',
        errorStyle: TextStyle(color: Colors.red),
      ),
      controller: controller,
      validator: InputConverter.validateOtp,
      onFieldSubmitted: (value) async {
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12.0,
          children: [
            Image.asset('assets/images/checked.png', width: 85, height: 85),
            const Text(
              'Account verified successfully',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
