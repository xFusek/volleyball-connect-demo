abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  AuthSignUpRequested({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  AuthPasswordResetRequested({required this.email});
}
