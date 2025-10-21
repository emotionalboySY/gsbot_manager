class ExactTimeMessage {
  final String? id;
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final String message;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExactTimeMessage({
    this.id,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.message,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ExactTimeMessage.fromJson(Map<String, dynamic> json) {
    return ExactTimeMessage(
      id: json['_id'],
      year: json['year'],
      month: json['month'],
      day: json['day'],
      hour: json['hour'],
      minute: json['minute'],
      message: json['message'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'message': message,
      'isActive': isActive,
    };
  }

  ExactTimeMessage copyWith({
    String? id,
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    String? message,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExactTimeMessage(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedDateTime {
    return '$year년 ${month.toString().padLeft(2, '0')}월 ${day.toString().padLeft(2, '0')}일 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class WeeklyMessage {
  final String? id;
  final String dayOfWeek;
  final int hour;
  final int minute;
  final String message;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WeeklyMessage({
    this.id,
    required this.dayOfWeek,
    required this.hour,
    required this.minute,
    required this.message,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory WeeklyMessage.fromJson(Map<String, dynamic> json) {
    return WeeklyMessage(
      id: json['_id'],
      dayOfWeek: json['dayOfWeek'],
      hour: json['hour'],
      minute: json['minute'],
      message: json['message'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'hour': hour,
      'minute': minute,
      'message': message,
      'isActive': isActive,
    };
  }

  WeeklyMessage copyWith({
    String? id,
    String? dayOfWeek,
    int? hour,
    int? minute,
    String? message,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyMessage(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedTime {
    return '$dayOfWeek요일 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static const List<String> daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];
}

class DailyMessage {
  final String? id;
  final int hour;
  final int minute;
  final String message;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailyMessage({
    this.id,
    required this.hour,
    required this.minute,
    required this.message,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory DailyMessage.fromJson(Map<String, dynamic> json) {
    return DailyMessage(
      id: json['_id'],
      hour: json['hour'],
      minute: json['minute'],
      message: json['message'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'message': message,
      'isActive': isActive,
    };
  }

  DailyMessage copyWith({
    String? id,
    int? hour,
    int? minute,
    String? message,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyMessage(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedTime {
    return '매일 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}