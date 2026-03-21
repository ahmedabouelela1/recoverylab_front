class BranchDayHours {
  /// Backend: 0=Sunday, 1=Monday … 6=Saturday
  final int dayOfWeek;
  final String openTime; // "HH:MM:SS"
  final String closeTime; // "HH:MM:SS"
  final bool isClosed;

  BranchDayHours({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory BranchDayHours.fromJson(Map<String, dynamic> json) => BranchDayHours(
        dayOfWeek: json['day_of_week'] as int,
        openTime: (json['open_time'] as String?) ?? '00:00:00',
        closeTime: (json['close_time'] as String?) ?? '23:59:00',
        isClosed: json['is_closed'] == true,
      );

  int get openHour => int.parse(openTime.split(':')[0]);
  int get closeHour => int.parse(closeTime.split(':')[0]);
}

class BranchSpecialDate {
  final String date; // "YYYY-MM-DD"
  /// Backend returns 'closed' | 'modified_hours'
  final String type;
  final String? openTime;
  final String? closeTime;
  final String? reason;

  BranchSpecialDate({
    required this.date,
    required this.type,
    this.openTime,
    this.closeTime,
    this.reason,
  });

  factory BranchSpecialDate.fromJson(Map<String, dynamic> json) =>
      BranchSpecialDate(
        date: json['date'] as String,
        type: ((json['type'] as String?) ?? 'closed').toLowerCase(),
        openTime: json['open_time'] as String?,
        closeTime: json['close_time'] as String?,
        reason: json['reason'] as String?,
      );

  bool get isClosed => type == 'closed';
}

class BranchSchedule {
  final List<BranchDayHours> hours;
  final List<BranchSpecialDate> specialDates;

  BranchSchedule({required this.hours, required this.specialDates});

  factory BranchSchedule.fromJson(Map<String, dynamic> json) => BranchSchedule(
        hours: ((json['hours'] as List?) ?? [])
            .map((h) => BranchDayHours.fromJson(h as Map<String, dynamic>))
            .toList(),
        specialDates: ((json['special_dates'] as List?) ?? [])
            .map((s) =>
                BranchSpecialDate.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  /// Returns the special date entry for [date], if any.
  BranchSpecialDate? specialDateFor(DateTime date) {
    final key = _fmt(date);
    try {
      return specialDates.firstWhere((s) => s.date == key);
    } catch (_) {
      return null;
    }
  }

  /// Returns available hour slots (as ints, 0–23) for [date].
  /// Returns null when the branch is closed that day.
  /// Backend uses day_of_week 0–6 (0=Sun, 1=Mon … 6=Sat).
  /// Dart DateTime.weekday is 1=Mon … 7=Sun (ISO).
  List<int>? slotsFor(DateTime date) {
    final special = specialDateFor(date);

    if (special != null) {
      if (special.isClosed) return null;
      if (special.openTime != null && special.closeTime != null) {
        return _slots(
          int.parse(special.openTime!.split(':')[0]),
          int.parse(special.closeTime!.split(':')[0]),
        );
      }
    }

    // Convert Dart weekday (1=Mon…7=Sun) → backend day_of_week (0=Sun, 1=Mon…6=Sat)
    final dartWeekday = date.weekday; // 1=Mon, 7=Sun
    final backendDay = dartWeekday == 7 ? 0 : dartWeekday; // Sun→0, Mon–Sat stay 1–6
    try {
      final day = hours.firstWhere((h) => h.dayOfWeek == backendDay);
      if (day.isClosed) return null;
      return _slots(day.openHour, day.closeHour);
    } catch (_) {
      return null; // no data for this day → treat as closed
    }
  }

  static List<int> _slots(int openHour, int closeHour) {
    if (closeHour <= openHour) return [];
    return List.generate(closeHour - openHour, (i) => openHour + i);
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
