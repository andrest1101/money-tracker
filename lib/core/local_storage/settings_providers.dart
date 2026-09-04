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
  return SettingsService(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
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

final budgetLimitProvider = NotifierProvider<BudgetLimit, double?>(
  BudgetLimit.new,
);

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

final appThemeModeProvider = NotifierProvider<AppThemeMode, ThemeMode>(
  AppThemeMode.new,
);

class UserName extends Notifier<String> {
  @override
  String build() => ref.watch(settingsServiceProvider).getUserName();

  Future<bool> setUserName(String name) async {
    try {
      await ref.read(settingsServiceProvider).setUserName(name);
      state = name;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final userNameProvider = NotifierProvider<UserName, String>(UserName.new);

class UserProfileType extends Notifier<String> {
  @override
  String build() => ref.watch(settingsServiceProvider).getUserProfileType();

  Future<bool> setProfileType(String profileType) async {
    try {
      await ref.read(settingsServiceProvider).setUserProfileType(profileType);
      state = profileType;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final userProfileTypeProvider = NotifierProvider<UserProfileType, String>(
  UserProfileType.new,
);

class ProfileAvatar extends Notifier<String> {
  @override
  String build() => ref.watch(settingsServiceProvider).getProfileAvatarId();

  Future<bool> setAvatar(String avatarId) async {
    try {
      await ref.read(settingsServiceProvider).setProfileAvatarId(avatarId);
      state = avatarId;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final profileAvatarProvider = NotifierProvider<ProfileAvatar, String>(
  ProfileAvatar.new,
);

class PrivacyMode extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsServiceProvider).getPrivacyMode();

  Future<bool> toggle() async {
    try {
      final newValue = !state;
      await ref.read(settingsServiceProvider).setPrivacyMode(newValue);
      state = newValue;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final privacyModeProvider = NotifierProvider<PrivacyMode, bool>(
  PrivacyMode.new,
);

class BudgetCycleDate extends Notifier<int> {
  @override
  int build() => ref.watch(settingsServiceProvider).getBudgetCycleDate();

  Future<bool> setDate(int day) async {
    try {
      await ref.read(settingsServiceProvider).setBudgetCycleDate(day);
      state = day;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final budgetCycleDateProvider = NotifierProvider<BudgetCycleDate, int>(
  BudgetCycleDate.new,
);

class LastSuccessfulSync extends Notifier<DateTime?> {
  @override
  DateTime? build() =>
      ref.watch(settingsServiceProvider).getLastSuccessfulSync();

  Future<void> markNow() async {
    final now = DateTime.now();
    try {
      await ref.read(settingsServiceProvider).setLastSuccessfulSync(now);
      state = now;
    } on SettingsServiceException {
      // Sync status remains valid for the current session even if its cache fails.
    }
  }
}

final lastSuccessfulSyncProvider =
    NotifierProvider<LastSuccessfulSync, DateTime?>(LastSuccessfulSync.new);

class OnboardingCompleted extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsServiceProvider).getOnboardingCompleted();

  Future<bool> complete() async {
    try {
      await ref.read(settingsServiceProvider).setOnboardingCompleted();
      state = true;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final onboardingCompletedProvider = NotifierProvider<OnboardingCompleted, bool>(
  OnboardingCompleted.new,
);

class HiddenExpenseCategories extends Notifier<List<String>> {
  @override
  List<String> build() => ref
      .watch(settingsServiceProvider)
      .getHiddenExpenseCategories();

  Future<bool> toggle(String category) async {
    final updated = [...state];
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    try {
      await ref
          .read(settingsServiceProvider)
          .setHiddenExpenseCategories(updated);
      state = updated;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final hiddenExpenseCategoriesProvider =
    NotifierProvider<HiddenExpenseCategories, List<String>>(
      HiddenExpenseCategories.new,
    );

class HiddenIncomeCategories extends Notifier<List<String>> {
  @override
  List<String> build() => ref
      .watch(settingsServiceProvider)
      .getHiddenIncomeCategories();

  Future<bool> toggle(String category) async {
    final updated = [...state];
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    try {
      await ref
          .read(settingsServiceProvider)
          .setHiddenIncomeCategories(updated);
      state = updated;
      return true;
    } on SettingsServiceException {
      return false;
    }
  }
}

final hiddenIncomeCategoriesProvider =
    NotifierProvider<HiddenIncomeCategories, List<String>>(
      HiddenIncomeCategories.new,
    );
