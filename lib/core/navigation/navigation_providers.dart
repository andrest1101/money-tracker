import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indeks tab aktif pada [AppShell].
///
/// Disimpan di Riverpod agar layar mana pun bisa meminta perpindahan tab
/// (contoh: "Lihat semua" dari Beranda membuka Riwayat) tanpa harus
/// menurunkan callback lewat konstruktor halaman.
class ShellTabIndex extends Notifier<int> {
  static const int home = 0;
  static const int savings = 1;
  static const int history = 2;
  static const int settings = 3;

  @override
  int build() => home;

  void select(int index) {
    state = index.clamp(home, settings);
  }
}

final shellTabIndexProvider = NotifierProvider<ShellTabIndex, int>(
  ShellTabIndex.new,
);
