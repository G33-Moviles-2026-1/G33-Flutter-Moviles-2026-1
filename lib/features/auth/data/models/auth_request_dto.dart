class LoginRequestDto {
  final String email;
  final String password;


  LoginRequestDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class SignUpRequestDto {
  final String email;
  final String password;
  final String firstSemester;

  SignUpRequestDto({
    required this.email,
    required this.password,
    required this.firstSemester,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'email': email,
      'password': password,
      'first_semester': firstSemester,
    };

    return data;
  }
}
