import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka Gmail, dengan fallback ke browser bila aplikasi Gmail tidak ada.
///
/// Memakai [defaultTargetPlatform] alih-alih `dart:io` agar tetap dapat
/// dikompilasi untuk target web.
Future<void> openGmail(BuildContext context) async {
  final uri = Uri.parse('https://mail.google.com/mail/u/0/#inbox');

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      const intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: 'https://mail.google.com/mail/u/0/#inbox',
        package: 'com.google.android.gm',
      );
      await intent.launch();
      return;
    } catch (_) {
      // Gmail tidak terpasang; lanjut membuka lewat browser.
    }
  }

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Gmail tidak dapat dibuka di perangkat ini.'),
      ),
    );
  }
}
