import 'package:intl/intl.dart';
import 'strings.dart';

String formatCurrency(double value) {
  final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);
  return formatter.format(value);
}

String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String formatDays(int days) {
  if (days == 0) return S.timeToday;
  if (days == 1) return S.timeDaysAgo(1);
  if (days < 30) return S.timeDaysAgo(days);
  if (days < 365) {
    final months = days ~/ 30;
    return months == 1 ? S.timeMonthsAgo(1) : S.timeMonthsAgo(months);
  }
  final years = days ~/ 365;
  final remainingMonths = (days % 365) ~/ 30;
  if (remainingMonths == 0) return years == 1 ? S.timeYearsAgo(1) : S.timeYearsAgo(years);
  return S.timeYearsMonthsAgo(years, remainingMonths);
}
