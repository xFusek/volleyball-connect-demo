abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
class AuthLogoutRequested extends AuthEvent {}