import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_entrance.dart';
import '../widgets/settings_content.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: const AppEntrance(child: SettingsContent()),
    );
  }
}
