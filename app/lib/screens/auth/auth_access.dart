import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../driver/driver_home_screen.dart';
import '../parent/parent_home_screen.dart';

enum AuthAccessFailure {
  profileNotFound,
  unsupportedRole,
  permissionDenied,
  unavailable,
}

Future<AuthAccessFailure?> openHomeForAuthenticatedUser(
  BuildContext context,
  User user,
) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) {
      await FirebaseAuth.instance.signOut();
      return AuthAccessFailure.profileNotFound;
    }

    final role = snapshot.data()?['role'];
    if (!context.mounted) return AuthAccessFailure.unavailable;

    if (role == 'parent') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
        (_) => false,
      );
      return null;
    }

    if (role == 'driver') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
        (_) => false,
      );
      return null;
    }

    await FirebaseAuth.instance.signOut();
    return AuthAccessFailure.unsupportedRole;
  } on FirebaseException catch (error) {
    if (error.code == 'permission-denied') {
      return AuthAccessFailure.permissionDenied;
    }
    return AuthAccessFailure.unavailable;
  }
}

String authAccessMessage(AuthAccessFailure failure) {
  return switch (failure) {
    AuthAccessFailure.profileNotFound =>
      'هذا الرقم غير مرتبط بحساب ولي أمر. راجع المدرسة أو الإدارة.',
    AuthAccessFailure.unsupportedRole =>
      'لا توجد صلاحية ولي أمر لهذا الحساب. تواصل مع إدارة المدرسة.',
    AuthAccessFailure.permissionDenied =>
      'لا توجد صلاحية للوصول إلى بيانات الحساب. تواصل مع إدارة المدرسة.',
    AuthAccessFailure.unavailable =>
      'تعذر قراءة بيانات الحساب حاليًا. تحقق من الاتصال وحاول مجددًا.',
  };
}
