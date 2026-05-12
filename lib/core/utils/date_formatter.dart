class DateFormatter {
  DateFormatter._();

  static const _monthFull = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const _monthShort = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String formatFull(DateTime date) =>
      '${date.day} ${_monthFull[date.month]} ${date.year}';

  static String formatShort(DateTime date) =>
      '${date.day} ${_monthShort[date.month]} ${date.year}';

  static String formatMonthYear(DateTime date) =>
      '${_monthFull[date.month]} ${date.year}';

  static String formatMonthShort(DateTime date) => _monthShort[date.month];
}
