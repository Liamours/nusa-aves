const List<String> _indoMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// Contoh: "24 Oktober 2025"
String formatIndonesianDate(DateTime date) {
  return '${date.day} ${_indoMonths[date.month - 1]} ${date.year}';
}

/// Contoh: "08.45"
String formatIndonesianTime(DateTime date) {
  return '${_twoDigits(date.hour)}.${_twoDigits(date.minute)}';
}

/// Contoh: "Hari Ini", "Kemarin", atau "24 Oktober 2025".
String formatRelativeDay(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final target = DateTime(date.year, date.month, date.day);
  final base = DateTime(today.year, today.month, today.day);
  final diff = base.difference(target).inDays;

  if (diff == 0) return 'Hari Ini';
  if (diff == 1) return 'Kemarin';
  return formatIndonesianDate(date);
}

/// Contoh: "Hari Ini, 08.45" - dipakai untuk baris ringkas seperti overlay kartu.
String formatRelativeDayTime(DateTime date, {DateTime? now}) {
  return '${formatRelativeDay(date, now: now)}, ${formatIndonesianTime(date)}';
}
