import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AuthColors {
  static const page = Color(0xFFF5F8FC);
  static const navy = Color(0xFF122033);
  static const ink = Color(0xFF17283B);
  static const secondary = Color(0xFF64768A);
  static const blue = Color(0xFF376F9D);
  static const green = Color(0xFF2B8060);
  static const border = Color(0xFFE1E8EF);
  static const error = Color(0xFFAF4944);
  static const errorBackground = Color(0xFFFFF0F0);
}

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.compact = false,
    this.leading,
  });

  final Widget child;
  final bool compact;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final heroHeight = compact ? 225.0 : 290.0;
    final panelTop = compact ? 205.0 : 257.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AuthColors.page,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final canvasHeight = constraints.maxHeight > 852
                  ? constraints.maxHeight
                  : 852.0;
              final panelHeight = canvasHeight - panelTop - 12;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: canvasHeight,
                      width: constraints.maxWidth.clamp(0.0, 600.0).toDouble(),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(color: AuthColors.page),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            height: heroHeight,
                            child: const ColoredBox(color: AuthColors.navy),
                          ),
                          Positioned(
                            left: 21,
                            top: compact ? 47 : 52,
                            child: leading ?? const AuthLanguageButton(),
                          ),
                          Positioned(
                            top: compact ? 93 : 119,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Image.asset(
                                'assets/branding/seer_logo_inverse.png',
                                width: 205,
                                height: 52,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          if (!compact)
                            const Positioned(
                              top: 179,
                              left: 35,
                              right: 35,
                              child: Text(
                                'رحلتهم بأمان، واطمئنانك دائمًا',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFC8D7E5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Positioned(
                            top: panelTop,
                            left: 20,
                            right: 20,
                            height: panelHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 19,
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}

class AuthLanguageButton extends StatelessWidget {
  const AuthLanguageButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 34,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onPressed ??
              () => showAuthInformationDialog(
                    context,
                    title: 'اللغة الإنجليزية غير متاحة حاليًا',
                    message:
                        'واجهة اللغة الإنجليزية غير متاحة حاليًا في النسخة التجريبية من سير، وستتوفر في إصدار لاحق.',
                  ),
          child: const Center(
            child: Text(
              'EN',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: AuthColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 34,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(17),
          child: const Center(
            child: Text(
              'رجوع',
              style: TextStyle(
                color: AuthColors.navy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.hasError = false,
    this.inputFormatters,
    this.onSubmitted,
    this.onChanged,
    this.textDirection = TextDirection.ltr,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool hasError;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AuthColors.error : AuthColors.border;
    final borderWidth = hasError ? 1.5 : 1.0;

    return SizedBox(
      height: 54,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        textDirection: textDirection,
        textAlign: TextAlign.left,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: const TextStyle(
          color: AuthColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintTextDirection: TextDirection.ltr,
          hintStyle: const TextStyle(
            color: AuthColors.secondary,
            fontSize: 13,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AuthColors.page,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? AuthColors.error : AuthColors.blue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor = AuthColors.navy,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: .55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class InlineAuthMessage extends StatelessWidget {
  const InlineAuthMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 47),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AuthColors.errorBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AuthColors.error,
                fontSize: 10,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const DecoratedBox(
            decoration: BoxDecoration(
              color: AuthColors.error,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: 7),
          ),
        ],
      ),
    );
  }
}

Future<void> showAuthInformationDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AuthColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AuthColors.secondary,
                      fontSize: 12,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 22),
                  AuthPrimaryButton(
                    label: 'حسنًا',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
