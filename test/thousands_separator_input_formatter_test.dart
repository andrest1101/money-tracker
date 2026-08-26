import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/core/utils/thousands_separator_input_formatter.dart';

void main() {
  final formatter = ThousandsSeparatorInputFormatter();

  TextEditingValue format(String newText, int caretOffset) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: caretOffset),
      ),
    );
  }

  group('ThousandsSeparatorInputFormatter', () {
    test('teks kosong tetap kosong', () {
      final result = format('', 0);
      expect(result.text, '');
    });

    test('angka di bawah 1000 tanpa pemisah', () {
      final result = format('500', 3);
      expect(result.text, '500');
    });

    test('1000 menjadi 1.000', () {
      final result = format('1000', 5);
      expect(result.text, '1.000');
      expect(result.selection.baseOffset, 5);
    });

    test('1300000 menjadi 1.300.000', () {
      final result = format('1300000', 9);
      expect(result.text, '1.300.000');
      expect(result.selection.baseOffset, 9);
    });

    test('pemisah yang diketik user ikut terformat ulang', () {
      final result = format('25.000', 6);
      expect(result.text, '25.000');
    });

    test('huruf dan simbol dibuang', () {
      final result = format('12a3b45c', 8);
      expect(result.text, '12.345');
    });

    test('kursor tetap di posisi benar saat menyisipkan angka di tengah',
        () {
      final result = format('15000', 3);
      expect(result.text, '15.000');
      expect(result.selection.baseOffset, 4);
    });

    test('menghapus digit memperbarui pemisah dengan benar', () {
      const previous = TextEditingValue(
        text: '10.000',
        selection: TextSelection.collapsed(offset: 6),
      );
      const newValue = TextEditingValue(
        text: '10.00',
        selection: TextSelection.collapsed(offset: 5),
      );
      final result = formatter.formatEditUpdate(previous, newValue);
      expect(result.text, '1.000');
      expect(result.selection.baseOffset, 5);
    });
  });
}
