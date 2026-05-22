enum UserStatus {
  incognito,
  busy,
  exercising,
  free,
  hangingOut,
  atHome,
  lunching;

  String get backendKey => switch (this) {
        UserStatus.incognito => 'incognito',
        UserStatus.busy => 'busy',
        UserStatus.exercising => 'exercising',
        UserStatus.free => 'free',
        UserStatus.hangingOut => 'hanging_out',
        UserStatus.atHome => 'at_home',
        UserStatus.lunching => 'lunching',
      };

  String get label => switch (this) {
        UserStatus.incognito => 'Incognito',
        UserStatus.busy => 'Busy',
        UserStatus.exercising => 'Exercising',
        UserStatus.free => 'Free',
        UserStatus.hangingOut => 'Hanging out',
        UserStatus.atHome => 'At home',
        UserStatus.lunching => 'Lunching',
      };

  static UserStatus fromBackendKey(String key) => UserStatus.values.firstWhere(
        (s) => s.backendKey == key,
        orElse: () => UserStatus.incognito,
      );
}
