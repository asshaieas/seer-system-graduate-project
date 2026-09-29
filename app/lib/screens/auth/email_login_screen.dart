import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_access.dart';
import 'auth_ui.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _inlineError;
  _EmailErrorField? _errorField;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_isValidEmail(email)) {
      setState(() {
        _inlineError =
            'صيغة البريد الإلكتروني غير صحيحة. تأكد من العنوان وأعد المحاولة.';
        _errorField = _EmailErrorField.email;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _inlineError = 'أدخل كلمة المرور للمتابعة.';
        _errorField = _EmailErrorField.password;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _inlineError = null;
      _errorField = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null || !mounted) {
        _setGeneralError('تعذر الحصول على بيانات المستخدم. حاول مجددًا.');
        return;
      }

      final failure = await openHomeForAuthenticatedUser(context, user);
      if (failure != null && mounted) {
        final message = switch (failure) {
          AuthAccessFailure.profileNotFound =>
            'هذا البريد غير مرتبط بحساب في سير. راجع المدرسة أو الإدارة.',
          AuthAccessFailure.unsupportedRole =>
            'لا توجد صلاحية ولي أمر لهذا الحساب. تواصل مع إدارة المدرسة.',
          AuthAccessFailure.permissionDenied =>
            'لا توجد صلاحية للوصول إلى بيانات الحساب. تواصل مع إدارة المدرسة.',
          AuthAccessFailure.unavailable =>
            'تعذر قراءة بيانات الحساب حاليًا. حاول مجددًا.',
        };
        _setGeneralError(message);
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      switch (error.code) {
        case 'invalid-email':
          setState(() {
            _inlineError =
                'صيغة البريد الإلكتروني غير صحيحة. تأكد من العنوان وأعد المحاولة.';
            _errorField = _EmailErrorField.email;
          });
          break;
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          setState(() {
            _inlineError =
                'كلمة المرور غير صحيحة. حاول مجددًا أو تواصل مع مدرستك.';
            _errorField = _EmailErrorField.password;
          });
          break;
        case 'user-disabled':
          _setGeneralError('تم تعطيل هذا الحساب. تواصل مع إدارة المدرسة.');
          break;
        case 'too-many-requests':
          _setGeneralError('توجد محاولات كثيرة. انتظر قليلًا ثم حاول مجددًا.');
          break;
        case 'network-request-failed':
          _setGeneralError('تعذر الاتصال بالشبكة. تحقق من الإنترنت.');
          break;
        default:
          _setGeneralError('تعذر تسجيل الدخول حاليًا. حاول مجددًا.');
          break;
      }
    } catch (error) {
      debugPrint('Email sign-in error: $error');
      if (mounted) _setGeneralError('حدث خطأ غير متوقع. حاول مجددًا.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  void _setGeneralError(String message) {
    if (!mounted) return;
    setState(() {
      _inlineError = message;
      _errorField = _EmailErrorField.general;
      _isLoading = false;
    });
  }

  void _clearError() {
    if (_inlineError == null) return;
    setState(() {
      _inlineError = null;
      _errorField = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            'الدخول بالبريد الإلكتروني',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AuthColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'أدخل بريدك الإلكتروني وكلمة المرور',
            textAlign: TextAlign.right,
            style: TextStyle(color: AuthColors.secondary, fontSize: 12),
          ),
          const SizedBox(height: 15),
          const Text(
            'البريد الإلكتروني',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AuthColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _emailController,
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            hasError: _errorField == _EmailErrorField.email,
            suffixIcon: const Icon(
              Icons.email_outlined,
              size: 19,
              color: AuthColors.secondary,
            ),
            onChanged: (_) => _clearError(),
          ),
          if (_inlineError != null &&
              _errorField == _EmailErrorField.email) ...[
            const SizedBox(height: 12),
            InlineAuthMessage(message: _inlineError!),
          ],
          const SizedBox(height: 15),
          const Text(
            'كلمة المرور',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AuthColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _passwordController,
            hintText: '••••••••',
            textInputAction: TextInputAction.done,
            obscureText: _obscurePassword,
            hasError: _errorField == _EmailErrorField.password,
            suffixIcon: const Icon(
              Icons.lock_outline,
              size: 19,
              color: AuthColors.secondary,
            ),
            prefixIcon: IconButton(
              tooltip: _obscurePassword
                  ? 'إظهار كلمة المرور'
                  : 'إخفاء كلمة المرور',
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
                color: AuthColors.secondary,
              ),
            ),
            onChanged: (_) => _clearError(),
            onSubmitted: (_) => _login(),
          ),
          if (_inlineError != null &&
              _errorField != _EmailErrorField.email) ...[
            const SizedBox(height: 12),
            InlineAuthMessage(message: _inlineError!),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showAuthInformationDialog(
                context,
                title: 'استعادة كلمة المرور',
                message:
                    'يرجى التواصل مع مدرستك أو إدارة المدرسة للحصول على بيانات الدخول أو طلب إعادة تعيين كلمة المرور.',
              ),
              child: const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(color: AuthColors.blue, fontSize: 11),
              ),
            ),
          ),
          AuthPrimaryButton(
            label: _inlineError == null ? 'تسجيل الدخول' : 'إعادة المحاولة',
            loading: _isLoading,
            onPressed: _login,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'الدخول باستخدام رقم الجوال',
              style: TextStyle(
                color: AuthColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AuthColors.border),
          const SizedBox(height: 8),
          const Text(
            'بيانات الدخول محمية ومخصّصة لحسابك في سير',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthColors.secondary,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

enum _EmailErrorField { email, password, general }
