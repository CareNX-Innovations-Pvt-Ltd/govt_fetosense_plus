import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

extension DateTimeExtension on DateTime {
  String format([String pattern = 'dd/MM/yyyy', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  String getMonth([String pattern = 'MMMM', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  String getDate([String pattern = 'dd', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  String getDay([String pattern = 'EEEE', String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this).toString().substring(0, 3);
  }

  int getAge() {
    DateTime endDate = DateTime.now();
    // '${(endDate.difference(DateTime.fromMillisecondsSinceEpoch(details['dateOfBirth'].seconds * 1000)).inDays ~/ 365)}',
    return ((endDate.year - year) * 12 + (endDate.month - month) + 1) ~/ 12;
  }

  int getGestAge() {
    final currentDate = DateTime.now();
    final differenceInDays = currentDate.difference(this).inDays;
    final weeksPassed = (differenceInDays / 7).floor(); // Calculate weeks
    return weeksPassed;
  }

}
