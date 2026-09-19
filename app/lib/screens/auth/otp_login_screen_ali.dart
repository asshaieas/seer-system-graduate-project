import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../driver/driver_home_screen.dart';
import '../parent/parent_home_screen.dart';

class OtpLoginScreenAli extends StatefulWidget {
  final String phoneNumber;

  // Android / iOS
  final String? verificationId;
  final int? resendToken;

  // Web
  final ConfirmationResult? confirmationResult;

  const OtpLoginScreenAli({
    super.key,
    required this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.confirmationResult,
  });

  @override
  State<OtpLoginScreenAli> createState() => _OtpLoginScreenAliState();
}

class _OtpLoginScreenAliState extends State<OtpLoginScreenAli> {
  static const Color _background = Color(0xFF122033);
  static const Color _gold = Color(0xFFC7A464);
  static const Color _blue = Color(0xFF3E6F9E);
  static const Color _secondaryText = Color(0xFF5C718A);
  static const Color _navy = Color(0xFF0B1320);

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  String? _verificationId;
  int? _resendToken;
  ConfirmationResult? _confirmationResult;

  Timer? _timer;
  int _remainingSeconds = 42;

  @override
  void initState() {
    super.initState();

    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _confirmationResult = widget.confirmationResult;

    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 42;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    final code = _otpCode;

    if (code.length != 6) {
      _showMessage('يرجى إدخال رمز التحقق المكون من 6 أرقام');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential credential;

      if (kIsWeb) {
        if (_confirmationResult == null) {
          _showMessage('انتهت جلسة التحقق، حاول إرسال الرمز من جديد');
          return;
        }

        credential = await _confirmationResult!.confirm(code);
      } else {
        if (_verificationId == null) {
          _showMessage('انتهت جلسة التحقق، حاول إرسال الرمز من جديد');
          return;
        }

        final phoneCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: code,
        );

        credential = await FirebaseAuth.instance.signInWithCredential(
          phoneCredential,
        );
      }

      final user = credential.user;

      if (user == null) {
        _showMessage('تعذر الحصول على بيانات المستخدم');
        return;
      }

      await _openUserHome(user);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint('OTP Firebase error: ${e.code}');
      debugPrint('OTP Firebase message: ${e.message}');

      String message;

      switch (e.code) {
        case 'invalid-verification-code':
          message = 'رمز التحقق غير صحيح';
          break;

        case 'session-expired':
          message = 'انتهت صلاحية رمز التحقق، أرسل رمزًا جديدًا';
          break;

        case 'invalid-verification-id':
          message = 'جلسة التحقق غير صالحة، حاول مرة أخرى';
          break;

        case 'too-many-requests':
          message = 'تم إجراء محاولات كثيرة، حاول لاحقًا';
          break;

        case 'network-request-failed':
          message = 'تعذر الاتصال بالشبكة';
          break;

        default:
          message = e.message ?? 'تعذر التحقق من الرمز';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      debugPrint('OTP unexpected error: $e');

      _showMessage('حدث خطأ غير متوقع أثناء التحقق');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openUserHome(User user) async {
    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDocument.exists) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        _showMessage(
          'تم التحقق من رقم الجوال، لكن لا توجد بيانات لهذا المستخدم',
        );

        return;
      }

      final data = userDocument.data();
      final role = data?['role'];

      if (!mounted) return;

      if (role == 'parent') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
          (route) => false,
        );
      } else if (role == 'driver') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
          (route) => false,
        );
      } else {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        _showMessage('دور المستخدم غير معروف');
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore role error: ${e.code}');
      debugPrint('Firestore role message: ${e.message}');

      if (e.code == 'permission-denied') {
        _showMessage('لا توجد صلاحية للوصول إلى بيانات المستخدم');
      } else {
        _showMessage('حدث خطأ أثناء قراءة بيانات المستخدم');
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0 || _isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      if (kIsWeb) {
        final result = await FirebaseAuth.instance.signInWithPhoneNumber(
          widget.phoneNumber,
        );

        if (!mounted) return;

        _confirmationResult = result;

        _clearOtp();
        _startTimer();

        _showMessage('تم إرسال رمز تحقق جديد');
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber,
          forceResendingToken: _resendToken,
          timeout: const Duration(seconds: 60),

          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              final result = await FirebaseAuth.instance.signInWithCredential(
                credential,
              );

              final user = result.user;

              if (user != null) {
                await _openUserHome(user);
              }
            } catch (e) {
              debugPrint('Automatic verification error: $e');
            }
          },

          verificationFailed: (FirebaseAuthException e) {
            if (!mounted) return;

            _showMessage(e.message ?? 'تعذر إعادة إرسال رمز التحقق');
          },

          codeSent: (String verificationId, int? resendToken) {
            if (!mounted) return;

            setState(() {
              _verificationId = verificationId;
              _resendToken = resendToken;
            });

            _clearOtp();
            _startTimer();

            _showMessage('تم إرسال رمز تحقق جديد');
          },

          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint('Resend Firebase error: ${e.code}');
      debugPrint('Resend Firebase message: ${e.message}');

      _showMessage(e.message ?? 'تعذر إعادة إرسال رمز التحقق');
    } catch (e) {
      if (!mounted) return;

      debugPrint('Resend unexpected error: $e');

      _showMessage('حدث خطأ أثناء إعادة إرسال الرمز');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }

    if (_focusNodes.isNotEmpty) {
      _focusNodes.first.requestFocus();
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '').split('');

      for (int i = 0; i < digits.length && i < 6; i++) {
        _controllers[i].text = digits[i];
      }

      final nextIndex = digits.length.clamp(0, 5);

      _focusNodes[nextIndex].requestFocus();

      setState(() {});

      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    setState(() {});
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(message),
        ),
      ),
    );
  }

  String _timerText() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _maskedPhone() {
    final phone = widget.phoneNumber;

    if (phone.length < 6) {
      return phone;
    }

    final end = phone.substring(phone.length - 2);

    return '+966 5X XXX XX$end';
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  _buildTopBar(),

                  const SizedBox(height: 75),

                  _buildLogo(),

                  const SizedBox(height: 76),

                  _buildHeader(),

                  const SizedBox(height: 18),

                  _buildOtpFields(),

                  const SizedBox(height: 18),

                  _buildVerifyButton(),

                  const SizedBox(height: 22),

                  _buildResendSection(),

                  const SizedBox(height: 16),

                  _buildChangePhoneButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 33,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                _showMessage('سيتم إضافة اللغة الإنجليزية لاحقًا');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

          const Spacer(),

          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'رجوع ←',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 40.5,
      width: double.infinity,
      child: Center(
        child: Image.asset(
          'assets/branding/seer_logo_inverse.png',
          width: 159.3,
          height: 40.5,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'أدخل رمز التحقق',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'أرسلنا رمزًا من 6 أرقام إلى\n${_maskedPhone()}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              height: 1.75,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFocused = _focusNodes[index].hasFocus;

        return Padding(
          padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
          child: SizedBox(
            width: 49,
            height: 58,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textInputAction: index == 5
                  ? TextInputAction.done
                  : TextInputAction.next,
              maxLength: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              onTap: () {
                setState(() {});
              },
              onChanged: (value) {
                _onOtpChanged(value, index);
              },
              onSubmitted: (_) {
                if (index == 5) {
                  _verifyOtp();
                }
              },
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isFocused ? _gold : Colors.transparent,
                    width: isFocused ? 2 : 0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _gold, width: 2),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _gold,
          disabledBackgroundColor: _gold.withValues(alpha: 0.55),
          foregroundColor: _navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
              )
            : const Text(
                'تحقق وتابع',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    if (_remainingSeconds > 0) {
      return Text(
        'لم يصلك الرمز؟ إعادة الإرسال خلال ${_timerText()}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return TextButton(
      onPressed: _isResending ? null : _resendOtp,
      child: _isResending
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'لم يصلك الرمز؟ إعادة الإرسال',
              style: TextStyle(
                color: _blue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: _blue,
              ),
            ),
    );
  }

  Widget _buildChangePhoneButton() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'تغيير رقم الجوال',
        style: TextStyle(
          color: _blue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: _blue,
        ),
      ),
    );
  }
}
