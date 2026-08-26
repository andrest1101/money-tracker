const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String formatDateShort(DateTime date) {
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}
