import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const String _separator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitBuffer = StringBuffer();
    for (var i = 0; i < newValue.text.length; i++) {
      final codeUnit = newValue.text.codeUnitAt(i);
      if (codeUnit >= 0x30 && codeUnit <= 0x39) {
        digitBuffer.writeCharCode(codeUnit);
      }
    }
    final digits = digitBuffer.toString();
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final digitsBeforeCaret =
        _countDigits(newValue.text, newValue.selection.baseOffset);

    final formatted = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      formatted.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        formatted.write(_separator);
      }
    }

    final text = formatted.toString();

    var separatorsBeforeCaret = 0;
    for (var i = 0; i < digitsBeforeCaret; i++) {
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        separatorsBeforeCaret++;
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset:
            (digitsBeforeCaret + separatorsBeforeCaret).clamp(0, text.length),
      ),
    );
  }

  int _countDigits(String text, int upTo) {
    var count = 0;
    final limit = upTo.clamp(0, text.length);
    for (var i = 0; i < limit; i++) {
      if (text.codeUnitAt(i) >= 0x30 && text.codeUnitAt(i) <= 0x39) {
        count++;
      }
    }
    return count;
  }
}
