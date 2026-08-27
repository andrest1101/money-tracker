import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsServiceException implements Exception {
  const SettingsServiceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'SettingsServiceException: $message'
      '${cause == null ? '' : ' | cause: $cause'}';
}

class SettingsService {
  SettingsService({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const String _budgetLimitKey = 'monthly_budget_limit';
  static const String _themeModeKey = 'theme_mode';
  static const String _savingsSortKey = 'savings_sort_option';

  double? getBudgetLimit() {
    try {
      return _sharedPreferences.getDouble(_budgetLimitKey);
    } catch (e) {
      throw SettingsServiceException('Gagal memuat batas anggaran', e);
    }
  }

  Future<void> setBudgetLimit(double? limit) async {
    try {
      if (limit == null) {
        await _sharedPreferences.remove(_budgetLimitKey);
        return;
      }
      await _sharedPreferences.setDouble(_budgetLimitKey, limit);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan batas anggaran', e);
    }
  }

  ThemeMode getThemeMode() {
    try {
      final stored = _sharedPreferences.getString(_themeModeKey);
      if (stored == null) return ThemeMode.system;
      for (final mode in ThemeMode.values) {
        if (mode.name == stored) return mode;
      }
      return ThemeMode.system;
    } catch (e) {
      throw SettingsServiceException('Gagal memuat mode tema', e);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _sharedPreferences.setString(_themeModeKey, mode.name);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan mode tema', e);
    }
  }

  String getSavingsSortOption() {
    try {
      return _sharedPreferences.getString(_savingsSortKey) ?? 'newest';
    } catch (e) {
      throw SettingsServiceException('Gagal memuat preferensi urutan target', e);
    }
  }

  Future<void> setSavingsSortOption(String option) async {
    try {
      await _sharedPreferences.setString(_savingsSortKey, option);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan preferensi urutan target', e);
    }
  }
}
