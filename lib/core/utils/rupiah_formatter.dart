String formatRupiah(double amount) {
  final isNegative = amount < 0;
  final rounded = amount.round().abs();
  final digits = rounded.toString();
  final buffered = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffered.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffered.write('.');
    }
  }

  final prefix = isNegative ? '-Rp ' : 'Rp ';
  return '$prefix$buffered';
}
