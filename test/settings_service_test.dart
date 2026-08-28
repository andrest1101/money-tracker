import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/core/local_storage/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SettingsService> createService(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(sharedPreferences: prefs);
  }

  group('SettingsService', () {
    test('budget limit & tema bernilai default saat belum pernah disimpan',
        () async {
      final service = await createService({});

      expect(service.getBudgetLimit(), isNull);
      expect(service.getThemeMode(), ThemeMode.system);
    });

    test('budget limit tersimpan dan terbaca kembali', () async {
      final service = await createService({});

      await service.setBudgetLimit(1500000);

      expect(service.getBudgetLimit(), 1500000);
    });

    test('setBudgetLimit null menghapus batas anggaran', () async {
      final service = await createService({'monthly_budget_limit': 900000.0});

      await service.setBudgetLimit(null);

      expect(service.getBudgetLimit(), isNull);
    });

    test('mode tema tersimpan dan terbaca kembali', () async {
      final service = await createService({});

      await service.setThemeMode(ThemeMode.dark);

      expect(service.getThemeMode(), ThemeMode.dark);
    });

    test('nilai tema tak dikenal jatuh kembali ke system', () async {
      final service = await createService({'theme_mode': 'nilai-aneh'});

      expect(service.getThemeMode(), ThemeMode.system);
    });

    test('tipe pengguna memiliki default dan dapat disimpan', () async {
      final service = await createService({});

      expect(service.getUserProfileType(), 'Mahasiswa');

      await service.setUserProfileType('Freelancer');

      expect(service.getUserProfileType(), 'Freelancer');
    });
  });
}
