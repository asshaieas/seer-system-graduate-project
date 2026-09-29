import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_access.dart';
import 'auth_ui.dart';
import 'email_login_screen.dart';
import 'otp_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  bool _isLoading = false;
  String? _inlineError;
  _PhoneErrorKind? _errorKind;

  Future<void> _sendVerificationCode() async {
    final localPhone = _normalizeLocalPhone(_phoneController.text);

    if (!RegExp(r'^05\d{8}$').hasMatch(localPhone)) {
      setState(() {
        _inlineError = 'رقم الجوال غير صحيح. أدخل ١٠ أرقام تبدأ بـ 05.';
        _errorKind = _PhoneErrorKind.invalid;
      });
      _phoneFocus.requestFocus();
      return;
    }

    final phone = '+966${localPhone.substring(1)}';
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _inlineError = null;
      _errorKind = null;
    });

    try {
      if (kIsWeb) {
        final confirmation =
            await FirebaseAuth.instance.signInWithPhoneNumber(phone);
        if (!mounted) return;
        await _openOtp(phone, confirmationResult: confirmation);
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (credential) async {
            try {
              final result =
                  await FirebaseAuth.instance.signInWithCredential(credential);
              final user = result.user;
              if (user == null || !mounted) return;
              final failure = await openHomeForAuthenticatedUser(context, user);
              if (failure != null && mounted) _setAccessFailure(failure);
            } on FirebaseAuthException catch (error) {
              if (mounted) _setFirebaseError(error);
            }
          },
          verificationFailed: (error) {
            if (mounted) _setFirebaseError(error);
          },
          codeSent: (verificationId, resendToken) async {
            if (!mounted) return;
            await _openOtp(
              phone,
              verificationId: verificationId,
              resendToken: resendToken,
            );
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) _setFirebaseError(error);
    } catch (error) {
      debugPrint('Phone sign-in error: $error');
      if (mounted) {
        setState(() {
          _inlineError =
              'تعذر إرسال رمز التحقق حاليًا. تحقق من الاتصال وحاول مجددًا.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openOtp(
    String phone, {
    String? verificationId,
    int? resendToken,
    ConfirmationResult? confirmationResult,
  }) async {
    if (!mounted) return;
    setState(() => _isLoading = false);

    final result = await Navigator.of(context).push<OtpLoginResult>(
      MaterialPageRoute(
        builder: (_) => OtpLoginScreen(
          phoneNumber: phone,
          verificationId: verificationId,
          resendToken: resendToken,
          confirmationResult: confirmationResult,
        ),
      ),
    );

    if (!mounted || result == null) return;
    switch (result) {
      case OtpLoginResult.profileNotFound:
        _setAccessFailure(AuthAccessFailure.profileNotFound);
        break;
      case OtpLoginResult.unsupportedRole:
        _setAccessFailure(AuthAccessFailure.unsupportedRole);
        break;
      case OtpLoginResult.permissionDenied:
        _setAccessFailure(AuthAccessFailure.permissionDenied);
        break;
      case OtpLoginResult.unavailable:
        _setAccessFailure(AuthAccessFailure.unavailable);
        break;
    }
  }

  void _setAccessFailure(AuthAccessFailure failure) {
    setState(() {
      _inlineError = authAccessMessage(failure);
      _errorKind = switch (failure) {
        AuthAccessFailure.profileNotFound => _PhoneErrorKind.unlinked,
        AuthAccessFailure.unsupportedRole => _PhoneErrorKind.wrongRole,
        _ => _PhoneErrorKind.other,
      };
      _isLoading = false;
    });
  }

  void _setFirebaseError(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-phone-number' =>
        'رقم الجوال غير صحيح. أدخل ١٠ أرقام تبدأ بـ 05.',
      'too-many-requests' =>
        'توجد محاولات كثيرة لهذا الرقم. انتظر قليلًا ثم حاول مجددًا.',
      'quota-exceeded' =>
        'تعذر إرسال رمز جديد حاليًا. حاول مرة أخرى لاحقًا.',
      'operation-not-allowed' =>
        'خدمة الدخول برقم الجوال غير مفعّلة حاليًا.',
      'network-request-failed' =>
        'تعذر الاتصال بالشبكة. تحقق من الإنترنت وحاول مجددًا.',
      'captcha-check-failed' || 'invalid-app-credential' =>
        'فشل التحقق الأمني. أعد المحاولة مرة أخرى.',
      _ => 'تعذر إرسال رمز التحقق حاليًا. حاول مجددًا.',
    };

    setState(() {
      _inlineError = message;
      _errorKind = error.code == 'invalid-phone-number'
          ? _PhoneErrorKind.invalid
          : _PhoneErrorKind.other;
      _isLoading = false;
    });
  }

  String _normalizeLocalPhone(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const latin = '0123456789';
    var normalized = value;
    for (var index = 0; index < arabic.length; index++) {
      normalized = normalized.replaceAll(arabic[index], latin[index]);
    }
    normalized = normalized.replaceAll(RegExp(r'\D'), '');
    if (normalized.startsWith('00966')) normalized = normalized.substring(5);
    if (normalized.startsWith('966')) normalized = normalized.substring(3);
    if (normalized.startsWith('5')) normalized = '0$normalized';
    return normalized;
  }

  String get _buttonLabel => switch (_errorKind) {
        _PhoneErrorKind.invalid => 'تصحيح رقم الجوال',
        _PhoneErrorKind.unlinked => 'استخدام رقم جوال آخر',
        _PhoneErrorKind.wrongRole => 'استخدام حساب آخر',
        _ => 'إرسال رمز التحقق',
      };

  void _onPrimaryPressed() {
    if (_errorKind == _PhoneErrorKind.invalid) {
      setState(() => _inlineError = null);
      _phoneFocus.requestFocus();
      return;
    }
    _sendVerificationCode();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'مرحبًا بك',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AuthColors.ink,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'أدخل رقم جوالك للوصول إلى حسابك بأمان',
            textAlign: TextAlign.right,
            style: TextStyle(color: AuthColors.secondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          const Text(
            'رقم الجوال',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AuthColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            hintText: '05X XXX XXXX',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            hasError: _inlineError != null,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
              LengthLimitingTextInputFormatter(10),
            ],
            prefixIcon: const Icon(
              Icons.phone_outlined,
              size: 20,
              color: AuthColors.blue,
            ),
            onChanged: (_) {
              if (_inlineError != null) {
                setState(() {
                  _inlineError = null;
                  _errorKind = null;
                });
              }
            },
            onSubmitted: (_) => _sendVerificationCode(),
          ),
          if (_inlineError != null) ...[
            const SizedBox(height: 12),
            InlineAuthMessage(message: _inlineError!),
          ],
          const SizedBox(height: 15),
          AuthPrimaryButton(
            label: _buttonLabel,
            loading: _isLoading,
            onPressed: _onPrimaryPressed,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
            ),
            child: const Text(
              'الدخول بالبريد الإلكتروني',
              style: TextStyle(
                color: AuthColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Row(
            children: [
              Expanded(child: Divider(color: AuthColors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'أو',
                  style: TextStyle(
                    color: AuthColors.secondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AuthColors.border)),
            ],
          ),
          const SizedBox(height: 10),
          AuthPrimaryButton(
            label: 'الدخول عبر نفاذ',
            backgroundColor: AuthColors.green,
            onPressed: () => showAuthInformationDialog(
              context,
              title: 'نفاذ غير متاح حاليًا',
              message:
                  'خدمة تسجيل الدخول عبر نفاذ لا تعمل في النسخة التجريبية من سير. يمكنك الدخول باستخدام رقم الجوال أو البريد الإلكتروني.',
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'بمتابعتك، أنت توافق على سياسة الخصوصية وشروط الاستخدام',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthColors.secondary,
              fontSize: 10,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PhoneErrorKind { invalid, unlinked, wrongRole, other }
