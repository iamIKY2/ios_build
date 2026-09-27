import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormatter = NumberFormat('#,###', 'vi_VN');

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount).trim();
  }

  static String formatAmountOnly(double amount) {
    return _numberFormatter.format(amount);
  }

  static String formatCompactCurrency(double amount) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B ₫';
    } else if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${amount.toInt()} ₫';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('HH:mm - dd/MM/yyyy', 'vi_VN').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(checkDate).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Hôm qua';
    } else if (difference == -1) {
      return 'Ngày mai';
    } else if (difference < 7 && difference > 0) {
      return '$difference ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }
}
