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
  static const String _userNameKey = 'user_name';
  static const String _privacyModeKey = 'privacy_mode';
  static const String _budgetCycleDateKey = 'budget_cycle_date';

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

  String getUserName() {
    try {
      return _sharedPreferences.getString(_userNameKey) ?? 'Pengguna';
    } catch (e) {
      throw SettingsServiceException('Gagal memuat nama pengguna', e);
    }
  }

  Future<void> setUserName(String name) async {
    try {
      await _sharedPreferences.setString(_userNameKey, name);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan nama pengguna', e);
    }
  }

  bool getPrivacyMode() {
    try {
      return _sharedPreferences.getBool(_privacyModeKey) ?? false;
    } catch (e) {
      throw SettingsServiceException('Gagal memuat mode privasi', e);
    }
  }

  Future<void> setPrivacyMode(bool isEnabled) async {
    try {
      await _sharedPreferences.setBool(_privacyModeKey, isEnabled);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan mode privasi', e);
    }
  }

  int getBudgetCycleDate() {
    try {
      return _sharedPreferences.getInt(_budgetCycleDateKey) ?? 1;
    } catch (e) {
      throw SettingsServiceException('Gagal memuat tanggal siklus anggaran', e);
    }
  }

  Future<void> setBudgetCycleDate(int day) async {
    try {
      await _sharedPreferences.setInt(_budgetCycleDateKey, day);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan tanggal siklus anggaran', e);
    }
  }
}
