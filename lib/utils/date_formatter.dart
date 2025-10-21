import 'package:intl/intl.dart';

class DateFormatter {
  // 한국어 날짜 포맷 (오전/오후 표시)
  static String formatDateTime(DateTime dateTime) {
    try {
      final formatter = DateFormat('yyyy년 M월 d일 a h:mm', 'ko_KR');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      // fallback
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // 24시간 형식
  static String formatDateTime24(DateTime dateTime) {
    try {
      final formatter = DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      // fallback
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // 짧은 날짜 포맷
  static String formatDate(DateTime dateTime) {
    try {
      final formatter = DateFormat('yyyy-MM-dd', 'ko_KR');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  // 시간만
  static String formatTime(DateTime dateTime) {
    try {
      final formatter = DateFormat('HH:mm', 'ko_KR');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // 상대 시간
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}년 전';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}