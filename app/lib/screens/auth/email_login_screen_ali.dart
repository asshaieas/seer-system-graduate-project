import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../driver/driver_home_screen.dart';
import '../parent/parent_home_screen.dart';

class EmailLoginScreenAli extends StatefulWidget {
  const EmailLoginScreenAli({super.key});

  @override
  State<EmailLoginScreenAli> createState() => _EmailLoginScreenAliState();
}

class _EmailLoginScreenAliState extends State<EmailLoginScreenAli> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color _background = Color(0xFF122033);
  static const Color _gold = Color(0xFFC7A464);
  static const Color _blue = Color(0xFF3E6F9E);
  static const Color _green = Color(0xFF3E8064);
  static const Color _secondaryText = Color(0xFF5C718A);
  static const Color _navy = Color(0xFF0B1320);
  static const Color _border = Color(0xFFD5CEC2);
  static const Color _fieldBorder = Color(0xFFE7E2D9);

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        _showMessage('تعذر الحصول على بيانات المستخدم');
        return;
      }

      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDocument.exists) {
        await FirebaseAuth.instance.signOut();

        _showMessage('لم يتم العثور على بيانات هذا المستخدم');
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

        _showMessage('دور المستخدم غير معروف');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          break;

        case 'invalid-email':
          message = 'البريد الإلكتروني غير صحيح';
          break;

        case 'user-disabled':
          message = 'تم تعطيل هذا الحساب';
          break;

        case 'too-many-requests':
          message = 'تم إجراء محاولات كثيرة، حاول لاحقًا';
          break;

        case 'network-request-failed':
          message = 'تعذر الاتصال بالشبكة';
          break;

        default:
          message = 'حدث خطأ أثناء تسجيل الدخول';
      }

      _showMessage(message);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      if (e.code == 'permission-denied') {
        _showMessage('لا يوجد صلاحية للوصول إلى بيانات المستخدم');
      } else {
        _showMessage('حدث خطأ أثناء قراءة بيانات المستخدم');
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Unexpected login error: $e');

      _showMessage('حدث خطأ غير متوقع');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              'خدمة التسجيل والدخول عبر نفاذ غير متوفرة حاليًا في النسخة التجريبية من SEER، وستتوفر في إصدار لاحق.',
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  _buildTopBar(),

                  const SizedBox(height: 65),

                  _buildLogo(),

                  const SizedBox(height: 38),

                  _buildHeader(),

                  const SizedBox(height: 18),

                  _buildEmailField(),

                  const SizedBox(height: 18),

                  _buildPasswordField(),

                  const SizedBox(height: 35),

                  _buildLoginButton(),

                  const SizedBox(height: 24),

                  _buildBackToPhoneButton(),

                  const SizedBox(height: 18),

                  _buildDivider(),

                  const SizedBox(height: 18),

                  _buildNafathButton(),

                  const SizedBox(height: 13),

                  _buildTerms(),

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
          SizedBox(
            height: 33,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  _showMessage('سيتم إضافة اللغة الإنجليزية لاحقًا');
                },
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الدخول بالبريد الإلكتروني',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            height: 1.55,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'استخدم البريد المسجل لدى إدارة المدرسة',
          textAlign: TextAlign.right,
          style: TextStyle(color: _secondaryText, fontSize: 13, height: 1.75),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'البريد الإلكتروني',
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
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'name@school.edu.sa',
              hintStyle: const TextStyle(color: _secondaryText, fontSize: 11),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              border: _fieldBorderStyle(),
              enabledBorder: _fieldBorderStyle(),
              focusedBorder: _fieldBorderStyle(color: _gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'كلمة السر',
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
            controller: _passwordController,
            obscureText: _obscurePassword,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: _secondaryText, fontSize: 16),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.only(
                left: 42,
                right: 42,
                top: 11,
                bottom: 11,
              ),
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: _secondaryText,
                ),
              ),
              border: _fieldBorderStyle(),
              enabledBorder: _fieldBorderStyle(),
              focusedBorder: _fieldBorderStyle(color: _gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorderStyle({
    Color color = _fieldBorder,
    double width = 0.7,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
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
                'تسجيل الدخول',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildBackToPhoneButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'الدخول باستخدام رقم الجوال',
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

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: _border, height: 1, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'أو',
            style: TextStyle(color: _secondaryText, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: _border, height: 1, thickness: 1)),
      ],
    );
  }

  Widget _buildNafathButton() {
    return SizedBox(
      width: double.infinity,
      height: 35,
      child: OutlinedButton(
        onPressed: _showNafathMessage,
        style: OutlinedButton.styleFrom(
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

  Widget _buildTerms() {
    return const Text(
      'بمتابعتك أنت توافق على سياسة الخصوصية وشروط الاستخدام',
      textAlign: TextAlign.center,
      style: TextStyle(color: _secondaryText, fontSize: 11, height: 1.7),
    );
  }
}
