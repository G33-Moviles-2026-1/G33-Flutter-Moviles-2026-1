import '../../domain/entities/google_calendar_auth_session.dart';

class GoogleCalendarAuthSessionModel {
  final String authUrl;
  final String state;

  const GoogleCalendarAuthSessionModel({
    required this.authUrl,
    required this.state,
  });

  factory GoogleCalendarAuthSessionModel.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarAuthSessionModel(
      authUrl: json['auth_url']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }

  GoogleCalendarAuthSession toEntity() {
    return GoogleCalendarAuthSession(authUrl: authUrl, state: state);
  }
}
