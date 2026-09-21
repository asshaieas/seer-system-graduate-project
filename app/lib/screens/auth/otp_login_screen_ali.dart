import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_access.dart';
import 'auth_ui.dart';

enum OtpLoginResult {
  profileNotFound,
  unsupportedRole,
  permissionDenied,
  unavailable,
}

class OtpLoginScreenAli extends StatefulWidget {
  const OtpLoginScreenAli({
    super.key,
    required this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.confirmationResult,
  });

  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final ConfirmationResult? confirmationResult;

  @override
  State<OtpLoginScreenAli> createState() => _OtpLoginScreenAliState();
}

class _OtpLoginScreenAliState extends State<OtpLoginScreenAli> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 45;
  bool _isLoading = false;
  bool _isResending = false;
  String? _inlineError;
  _OtpErrorKind? _errorKind;

  String? _verificationId;
  int? _resendToken;
  ConfirmationResult? _confirmationResult;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _confirmationResult = widget.confirmationResult;
    for (final node in _focusNodes) {
      node.addListener(_refreshFocus);
    }
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  void _refreshFocus() {
    if (mounted) setState(() {});
  }

  String get _otp => _controllers.map((controller) => controller.text).join();

  Future<void> _verifyOtp() async {
    if (_errorKind == _OtpErrorKind.expired) {
      await _resendOtp();
      return;
    }

    if (_otp.length != 6) {
      setState(() {
        _inlineError = 'أدخل الأرقام الستة التي وصلت إلى جوالك.';
        _errorKind = _OtpErrorKind.incomplete;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _inlineError = null;
      _errorKind = null;
    });

    try {
      final UserCredential credential;
      if (kIsWeb) {
        final confirmation = _confirmationResult;
        if (confirmation == null) {
          _setExpired();
          return;
        }
        credential = await confirmation.confirm(_otp);
      } else {
        final verificationId = _verificationId;
        if (verificationId == null) {
          _setExpired();
          return;
        }
        credential = await FirebaseAuth.instance.signInWithCredential(
          PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: _otp,
          ),
        );
      }

      final user = credential.user;
      if (user == null || !mounted) {
        _setGenericError('تعذر الحصول على بيانات المستخدم. حاول مجددًا.');
        return;
      }

      final failure = await openHomeForAuthenticatedUser(context, user);
      if (failure != null && mounted) {
        Navigator.of(context).pop(_toOtpResult(failure));
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      switch (error.code) {
        case 'invalid-verification-code':
          setState(() {
            _inlineError =
                'رمز التحقق غير صحيح. راجع الأرقام وحاول مجددًا.';
            _errorKind = _OtpErrorKind.invalid;
          });
          break;
        case 'session-expired':
        case 'invalid-verification-id':
          _setExpired();
          break;
        case 'too-many-requests':
          _setGenericError('توجد محاولات كثيرة. انتظر قليلًا ثم حاول مجددًا.');
          break;
        case 'network-request-failed':
          _setGenericError('تعذر الاتصال بالشبكة. تحقق من الإنترنت.');
          break;
        default:
          _setGenericError('تعذر التحقق من الرمز. حاول مجددًا.');
          break;
      }
    } catch (error) {
      debugPrint('OTP verification error: $error');
      if (mounted) _setGenericError('حدث خطأ غير متوقع. حاول مجددًا.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending || (_remainingSeconds > 0 && _errorKind != _OtpErrorKind.expired)) {
      return;
    }

    setState(() {
      _isResending = true;
      _inlineError = null;
      _errorKind = null;
    });

    try {
      if (kIsWeb) {
        _confirmationResult = await FirebaseAuth.instance
            .signInWithPhoneNumber(widget.phoneNumber);
        _resetAfterResend();
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber,
          forceResendingToken: _resendToken,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (credential) async {
            final result =
                await FirebaseAuth.instance.signInWithCredential(credential);
            final user = result.user;
            if (user == null || !mounted) return;
            final failure = await openHomeForAuthenticatedUser(context, user);
            if (failure != null && mounted) {
              Navigator.of(context).pop(_toOtpResult(failure));
            }
          },
          verificationFailed: (error) {
            if (mounted) _setGenericError(_resendErrorMessage(error));
          },
          codeSent: (verificationId, resendToken) {
            _verificationId = verificationId;
            _resendToken = resendToken;
            if (mounted) _resetAfterResend();
          },
          codeAutoRetrievalTimeout: (verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) _setGenericError(_resendErrorMessage(error));
    } catch (error) {
      debugPrint('OTP resend error: $error');
      if (mounted) _setGenericError('تعذر إعادة إرسال الرمز. حاول مجددًا.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String _resendErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'too-many-requests' =>
        'توجد طلبات كثيرة لإرسال الرمز. انتظر قليلًا ثم حاول مجددًا.',
      'network-request-failed' =>
        'تعذر الاتصال بالشبكة. تحقق من الإنترنت.',
      _ => 'تعذر إعادة إرسال الرمز. حاول مجددًا.',
    };
  }

  void _resetAfterResend() {
    _clearOtp();
    _startTimer();
    setState(() {
      _inlineError = null;
      _errorKind = null;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (_inlineError != null) {
      setState(() {
        _inlineError = null;
        _errorKind = null;
      });
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _focusNodes[index].unfocus();
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _setExpired() {
    if (!mounted) return;
    setState(() {
      _inlineError = 'انتهت صلاحية رمز التحقق. اطلب رمزًا جديدًا.';
      _errorKind = _OtpErrorKind.expired;
      _isLoading = false;
    });
  }

  void _setGenericError(String message) {
    if (!mounted) return;
    setState(() {
      _inlineError = message;
      _errorKind = _OtpErrorKind.other;
      _isLoading = false;
    });
  }

  OtpLoginResult _toOtpResult(AuthAccessFailure failure) {
    return switch (failure) {
      AuthAccessFailure.profileNotFound => OtpLoginResult.profileNotFound,
      AuthAccessFailure.unsupportedRole => OtpLoginResult.unsupportedRole,
      AuthAccessFailure.permissionDenied => OtpLoginResult.permissionDenied,
      AuthAccessFailure.unavailable => OtpLoginResult.unavailable,
    };
  }

  String get _fullPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('966')
        ? '0${digits.substring(3)}'
        : digits.startsWith('5')
            ? '0$digits'
            : digits;

    if (local.length == 10) {
      return '${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
    }
    return local;
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _buttonLabel => switch (_errorKind) {
        _OtpErrorKind.invalid => 'إعادة المحاولة',
        _OtpErrorKind.expired => 'إعادة إرسال رمز جديد',
        _ => 'تأكيد رمز التحقق',
      };

  @override
  void dispose() {
    _timer?.cancel();
    for (final node in _focusNodes) {
      node.removeListener(_refreshFocus);
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      compact: true,
      leading: AuthBackButton(onPressed: () => Navigator.of(context).pop()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'التحقق من رقم الجوال',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AuthColors.ink,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'أدخل رمز التحقق المرسل إلى رقم جوالك',
            textAlign: TextAlign.right,
            style: TextStyle(color: AuthColors.secondary, fontSize: 12),
          ),
          const SizedBox(height: 11),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AuthColors.page,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'أرسلنا كود التحقق إلى رقم',
                  style: TextStyle(
                    color: AuthColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _fullPhone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AuthColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'الرمز المكوّن من ٦ أرقام',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AuthColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, _buildOtpBox),
            ),
          ),
          const SizedBox(height: 12),
          if (_inlineError != null)
            InlineAuthMessage(message: _inlineError!)
          else
            const Text(
              'تبدأ كتابة الأرقام من الخانة اليسرى',
              textAlign: TextAlign.right,
              style: TextStyle(color: AuthColors.secondary, fontSize: 10),
            ),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: _buttonLabel,
            loading: _isLoading || _isResending,
            onPressed: _verifyOtp,
          ),
          const SizedBox(height: 12),
          if (_errorKind == _OtpErrorKind.expired)
            const Text(
              'انتهت صلاحية الرمز السابق',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuthColors.secondary, fontSize: 12),
            )
          else if (_remainingSeconds > 0)
            Text(
              'إعادة إرسال الرمز بعد $_timerText',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AuthColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            TextButton(
              onPressed: _isResending ? null : _resendOtp,
              child: const Text(
                'إعادة إرسال الرمز',
                style: TextStyle(color: AuthColors.blue, fontSize: 12),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'تغيير رقم الجوال',
              style: TextStyle(
                color: AuthColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(color: AuthColors.border),
          const SizedBox(height: 8),
          const Text(
            'لا تشارك رمز التحقق مع أي شخص',
            textAlign: TextAlign.center,
            style: TextStyle(color: AuthColors.secondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final hasError = _inlineError != null;
    final focused = _focusNodes[index].hasFocus;
    final borderColor = hasError
        ? AuthColors.error
        : focused
            ? AuthColors.blue
            : AuthColors.border;

    return SizedBox(
      width: 47,
      height: 53,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textInputAction:
            index == 5 ? TextInputAction.done : TextInputAction.next,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AuthColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        onChanged: (value) => _onOtpChanged(value, index),
        onSubmitted: (_) {
          if (index == 5) _verifyOtp();
        },
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
        ),
      ),
    );
  }
}

enum _OtpErrorKind { incomplete, invalid, expired, other }
