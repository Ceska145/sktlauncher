/// Bildirim Ayarları Entity
class NotificationSettings {
  final bool enabled;
  final List<int> alertDays; // Kaç gün önceden uyarı verilecek [1, 3, 7, 14, 30]
  final bool dailyReport;
  final String dailyReportTime; // HH:mm formatında
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationSettings({
    this.enabled = true,
    this.alertDays = const [1, 3, 7],
    this.dailyReport = false,
    this.dailyReportTime = '09:00',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? enabled,
    List<int>? alertDays,
    bool? dailyReport,
    String? dailyReportTime,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      alertDays: alertDays ?? this.alertDays,
      dailyReport: dailyReport ?? this.dailyReport,
      dailyReportTime: dailyReportTime ?? this.dailyReportTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'alert_days': alertDays,
      'daily_report': dailyReport,
      'daily_report_time': dailyReportTime,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      alertDays: (json['alert_days'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [1, 3, 7],
      dailyReport: json['daily_report'] as bool? ?? false,
      dailyReportTime: json['daily_report_time'] as String? ?? '09:00',
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
    );
  }
}
