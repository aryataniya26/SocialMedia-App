
import 'package:intl/intl.dart';

class DateFormatter {
  // Format Date: 01 Jan 2024
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format Time: 10:30 AM
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Format DateTime: 01 Jan 2024, 10:30 AM
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // Format Relative Time: 2 hours ago, Yesterday, etc.
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  // Parse Date String: "01/01/2024" to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get Day of Week: Monday, Tuesday, etc.
  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Get Month Name: January, February, etc.
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }
}