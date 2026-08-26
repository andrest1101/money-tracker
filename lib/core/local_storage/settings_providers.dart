import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider wajib di-override di main.dart sebelum runApp',
  );
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

class BudgetLimit extends Notifier<double?> {
  @override
  double? build() => ref.watch(settingsServiceProvider).getBudgetLimit();

  Future<bool> setBudgetLimit(double? limit) async {
    try {
      await ref.read(settingsServiceProvider).setBudgetLimit(limit);
      state = limit;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final budgetLimitProvider =
    NotifierProvider<BudgetLimit, double?>(BudgetLimit.new);

class AppThemeMode extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(settingsServiceProvider).getThemeMode();

  Future<bool> setThemeMode(ThemeMode mode) async {
    try {
      await ref.read(settingsServiceProvider).setThemeMode(mode);
      state = mode;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeMode, ThemeMode>(AppThemeMode.new);
