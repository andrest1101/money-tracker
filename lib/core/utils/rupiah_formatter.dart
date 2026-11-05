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

const List<String> _numberWords = [
  'nol',
  'satu',
  'dua',
  'tiga',
  'empat',
  'lima',
  'enam',
  'tujuh',
  'delapan',
  'sembilan',
  'sepuluh',
  'sebelas',
];

/// Versi nominal yang terbaca pembaca layar, contoh:
/// `formatRupiahSpoken(-12000)` → `minus dua belas ribu rupiah`.
///
/// Dipakai oleh [Semantics] pada komponen nominal agar pengguna pembaca layar
/// tidak mendengar deretan angka mentah.
String formatRupiahSpoken(double amount) {
  final rounded = amount.round();
  final isNegative = rounded < 0;
  final words = _spellNumber(rounded.abs());
  return '${isNegative ? 'minus ' : ''}$words rupiah';
}

String _spellNumber(int value) {
  if (value < 0) {
    return 'minus ${_spellNumber(-value)}';
  }
  if (value < _numberWords.length) {
    return _numberWords[value];
  }
  if (value < 20) {
    return '${_numberWords[value - 10]} belas';
  }
  if (value < 100) {
    final tens = value ~/ 10;
    final remainder = value % 10;
    return '${_numberWords[tens]} puluh'
        '${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
  }
  if (value < 200) {
    final remainder = value - 100;
    return 'seratus${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
  }
  if (value < 1000) {
    final hundreds = value ~/ 100;
    final remainder = value % 100;
    return '${_spellNumber(hundreds)} ratus'
        '${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
  }
  if (value < 2000) {
    final remainder = value - 1000;
    return 'seribu${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
  }
  if (value < 1000000) {
    final thousands = value ~/ 1000;
    final remainder = value % 1000;
    return '${_spellNumber(thousands)} ribu'
        '${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
  }
  if (value < 1000000000) {
    final millions = value ~/ 1000000;
    final remainder = value % 1000000;
    return '${_spellNumber(millions)} juta'
        '${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
  }
  if (value < 1000000000000) {
    final billions = value ~/ 1000000000;
    final remainder = value % 1000000000;
    return '${_spellNumber(billions)} miliar'
        '${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
  }
  final trillions = value ~/ 1000000000000;
  final remainder = value % 1000000000000;
  return '${_spellNumber(trillions)} triliun'
      '${remainder == 0 ? '' : ' ${_spellNumber(remainder)}'}';
}
