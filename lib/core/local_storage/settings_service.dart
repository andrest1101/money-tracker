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
  static const String _userProfileTypeKey = 'user_profile_type';
  static const String _privacyModeKey = 'privacy_mode';
  static const String _budgetCycleDateKey = 'budget_cycle_date';
  static const String _lastSyncKey = 'last_successful_sync';
  static const String _profileAvatarKey = 'profile_avatar_id';
  static const String _onboardingCompletedKey = 'onboarding_completed';

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
      throw SettingsServiceException(
        'Gagal memuat preferensi urutan target',
        e,
      );
    }
  }

  Future<void> setSavingsSortOption(String option) async {
    try {
      await _sharedPreferences.setString(_savingsSortKey, option);
    } catch (e) {
      throw SettingsServiceException(
        'Gagal menyimpan preferensi urutan target',
        e,
      );
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

  String getUserProfileType() {
    try {
      return _sharedPreferences.getString(_userProfileTypeKey) ?? 'Mahasiswa';
    } catch (e) {
      throw SettingsServiceException('Gagal memuat tipe pengguna', e);
    }
  }

  Future<void> setUserProfileType(String profileType) async {
    try {
      await _sharedPreferences.setString(_userProfileTypeKey, profileType);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan tipe pengguna', e);
    }
  }

  String getProfileAvatarId() {
    try {
      return _sharedPreferences.getString(_profileAvatarKey) ?? 'sunrise';
    } catch (e) {
      throw SettingsServiceException('Gagal memuat avatar profil', e);
    }
  }

  Future<void> setProfileAvatarId(String avatarId) async {
    try {
      await _sharedPreferences.setString(_profileAvatarKey, avatarId);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan avatar profil', e);
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
      throw SettingsServiceException(
        'Gagal menyimpan tanggal siklus anggaran',
        e,
      );
    }
  }

  DateTime? getLastSuccessfulSync() {
    try {
      final raw = _sharedPreferences.getString(_lastSyncKey);
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (e) {
      throw SettingsServiceException('Gagal memuat waktu sinkronisasi', e);
    }
  }

  Future<void> setLastSuccessfulSync(DateTime value) async {
    try {
      await _sharedPreferences.setString(_lastSyncKey, value.toIso8601String());
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan waktu sinkronisasi', e);
    }
  }

  bool getOnboardingCompleted() {
    try {
      final stored = _sharedPreferences.getBool(_onboardingCompletedKey);
      if (stored != null) return stored;

      // Existing installs already have local preferences from the old app.
      final isExistingInstall = [
        _themeModeKey,
        _budgetLimitKey,
        _userNameKey,
        _privacyModeKey,
        _budgetCycleDateKey,
        _lastSyncKey,
      ].any(_sharedPreferences.containsKey);
      return isExistingInstall;
    } catch (e) {
      throw SettingsServiceException('Gagal memuat status onboarding', e);
    }
  }

  Future<void> setOnboardingCompleted() async {
    try {
      await _sharedPreferences.setBool(_onboardingCompletedKey, true);
    } catch (e) {
      throw SettingsServiceException('Gagal menyimpan status onboarding', e);
    }
  }
}
