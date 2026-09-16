import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'email_login_screen_ali.dart';
import 'otp_login_screen_ali.dart';

class LoginScreenAli extends StatefulWidget {
  const LoginScreenAli({super.key});

  @override
  State<LoginScreenAli> createState() => _LoginScreenAliState();
}

class _LoginScreenAliState extends State<LoginScreenAli> {
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  static const Color _background = Color(0xFF122033);
  static const Color _gold = Color(0xFFC7A464);
  static const Color _blue = Color(0xFF3E6F9E);
  static const Color _green = Color(0xFF3E8064);
  static const Color _secondaryText = Color(0xFF5C718A);
  static const Color _navy = Color(0xFF0B1320);
  static const Color _border = Color(0xFFD5CEC2);
  static const Color _fieldBorder = Color(0xFFE7E2D9);

  // =========================================================
  // PHONE LOGIN
  // =========================================================

  Future<void> _sendVerificationCode() async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showMessage('يرجى إدخال رقم الجوال');
      return;
    }

    phone = _normalizeSaudiPhone(phone);

    if (!_isValidSaudiPhone(phone)) {
      _showMessage('يرجى إدخال رقم جوال سعودي صحيح');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        await _sendCodeOnWeb(phone);
      } else {
        await _sendCodeOnMobile(phone);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Firebase Auth Error Code: ${e.code}');
      debugPrint('Firebase Auth Error Message: ${e.message}');

      _showMessage(_firebaseMessage(e));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Unexpected Phone Auth Error: $e');

      _showMessage('حدث خطأ غير متوقع أثناء إرسال رمز التحقق');
    }
  }

  String _normalizeSaudiPhone(String phone) {
    phone = phone
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    if (phone.startsWith('00966')) {
      return '+966${phone.substring(5)}';
    }

    if (phone.startsWith('966')) {
      return '+$phone';
    }

    if (phone.startsWith('05')) {
      return '+966${phone.substring(1)}';
    }

    if (phone.startsWith('5')) {
      return '+966$phone';
    }

    return phone;
  }

  bool _isValidSaudiPhone(String phone) {
    final regex = RegExp(r'^\+9665\d{8}$');
    return regex.hasMatch(phone);
  }

  // =========================================================
  // WEB OTP
  // =========================================================

  Future<void> _sendCodeOnWeb(String phone) async {
    final confirmationResult = await FirebaseAuth.instance
        .signInWithPhoneNumber(phone);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpLoginScreenAli(
          phoneNumber: phone,
          confirmationResult: confirmationResult,
        ),
      ),
    );
  }

  // =========================================================
  // ANDROID / IOS OTP
  // =========================================================

  Future<void> _sendCodeOnMobile(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final result = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );

          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          if (result.user != null) {
            /*
             * في بعض أجهزة Android قد يتحقق Firebase
             * تلقائيًا بدون أن يحتاج المستخدم كتابة OTP.
             *
             * في الوقت الحالي نوضح للمستخدم نجاح العملية.
             * شاشة OTP نفسها تتولى قراءة role عند الإدخال اليدوي.
             */
            _showMessage('تم التحقق من رقم الجوال تلقائيًا');
          }
        } on FirebaseAuthException catch (e) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          _showMessage(_firebaseMessage(e));
        } catch (e) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          debugPrint('Automatic Verification Error: $e');

          _showMessage('حدث خطأ أثناء التحقق التلقائي');
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        debugPrint('Phone Verification Failed: ${e.code}');

        debugPrint('Phone Verification Message: ${e.message}');

        _showMessage(_firebaseMessage(e));
      },

      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        debugPrint('OTP Code Sent');
        debugPrint('Phone: $phone');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpLoginScreenAli(
              phoneNumber: phone,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          ),
        );
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('OTP Auto Retrieval Timeout');

        debugPrint('Verification ID: $verificationId');
      },
    );
  }

  // =========================================================
  // FIREBASE ERRORS
  // =========================================================

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'رقم الجوال غير صحيح';

      case 'too-many-requests':
        return 'تم إجراء محاولات كثيرة، حاول لاحقًا';

      case 'quota-exceeded':
        return 'تم تجاوز حد رسائل التحقق، حاول لاحقًا';

      case 'operation-not-allowed':
        return 'تسجيل الدخول برقم الجوال غير مفعّل في Firebase';

      case 'network-request-failed':
        return 'تعذر الاتصال بالشبكة، تحقق من الإنترنت';

      case 'captcha-check-failed':
        return 'فشل التحقق الأمني، حاول مرة أخرى';

      case 'invalid-app-credential':
        return 'إعدادات التحقق الخاصة بالتطبيق غير مكتملة';

      case 'app-not-authorized':
        return 'هذا التطبيق غير مصرح له باستخدام تسجيل الدخول بالجوال';

      case 'web-context-cancelled':
        return 'تم إلغاء عملية التحقق';

      case 'web-context-already-presented':
        return 'عملية التحقق مفتوحة بالفعل';

      default:
        return e.message ?? 'تعذر إرسال رمز التحقق';
    }
  }

  // =========================================================
  // EMAIL LOGIN
  // =========================================================

  void _openEmailLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmailLoginScreenAli()),
    );
  }

  // =========================================================
  // NAFATH
  // =========================================================

  void _showNafathMessage() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF192A40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'الدخول عبر نفاذ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'خدمة التسجيل والدخول عبر نفاذ غير متوفرة حاليًا في النسخة التجريبية من سَير وستتوفر في إصدار لاحق.',
              style: TextStyle(color: Color(0xFFB3C0D0), height: 1.7),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'حسنًا',
                  style: TextStyle(color: _gold, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // LANGUAGE
  // =========================================================

  void _showLanguageMessage() {
    _showMessage('سيتم إضافة اللغة الإنجليزية لاحقًا');
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(message),
        ),
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),

                        _buildTopBar(),

                        const SizedBox(height: 68),

                        _buildLogo(),

                        const SizedBox(height: 67),

                        _buildWelcomeSection(),

                        const SizedBox(height: 24),

                        _buildPhoneField(),

                        const SizedBox(height: 30),

                        _buildSendOtpButton(),

                        const SizedBox(height: 24),

                        _buildEmailLoginButton(),

                        const SizedBox(height: 18),

                        _buildDivider(),

                        const SizedBox(height: 18),

                        _buildNafathButton(),

                        const SizedBox(height: 13),

                        _buildTerms(),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar() {
    return SizedBox(
      height: 33,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            height: 33,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _showLanguageMessage,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Center(
                    child: Text(
                      'EN',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // LOGO
  // =========================================================

  Widget _buildLogo() {
    return SizedBox(
      height: 51,
      width: double.infinity,
      child: Center(
        child: Image.asset(
          'assets/branding/seer_logo_inverse.png',
          width: 200.6,
          height: 51,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildWelcomeSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'مرحبًا بك',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'أدخل رقم جوالك للوصول إلى حسابك بأمان',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: _secondaryText,
            fontSize: 14,
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PHONE FIELD
  // =========================================================

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'رقم الجوال',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 40,
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            onSubmitted: (_) {
              if (!_isLoading) {
                _sendVerificationCode();
              }
            },
            style: const TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '05X XXX XXXX',
              hintStyle: const TextStyle(
                color: _secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _fieldBorder, width: 0.7),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _fieldBorder, width: 0.7),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _gold, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // OTP BUTTON
  // =========================================================

  Widget _buildSendOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendVerificationCode,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _gold,
          disabledBackgroundColor: _gold.withValues(alpha: 0.55),
          foregroundColor: _navy,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: _navy),
              )
            : const Text(
                'إرسال رمز التحقق',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // =========================================================
  // EMAIL BUTTON
  // =========================================================

  Widget _buildEmailLoginButton() {
    return SizedBox(
      height: 28,
      child: TextButton(
        onPressed: _openEmailLogin,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: _blue,
        ),
        child: const Text(
          'الدخول بالبريد الإلكتروني',
          style: TextStyle(
            color: _blue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: _blue,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // DIVIDER
  // =========================================================

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: _border, height: 1, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'أو',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(child: Divider(color: _border, height: 1, thickness: 1)),
      ],
    );
  }

  // =========================================================
  // NAFATH BUTTON
  // =========================================================

  Widget _buildNafathButton() {
    return SizedBox(
      width: double.infinity,
      height: 35,
      child: OutlinedButton(
        onPressed: _showNafathMessage,
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: _green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          side: const BorderSide(color: _border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'الدخول عبر نفاذ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // =========================================================
  // TERMS
  // =========================================================

  Widget _buildTerms() {
    return const Text(
      'بمتابعتك أنت توافق على سياسة الخصوصية وشروط الاستخدام',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _secondaryText,
        fontSize: 11,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
