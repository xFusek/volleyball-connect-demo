import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

enum Routes {
  root("/"),
  login("/login"),
  signup("/signup"),
  home("/home"),
  ;

  const Routes(this.path);
  final String path;
}

class AppRoute {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: Routes.root.path,
        name: Routes.root.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(
          child: WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: Routes.login.path,
        name: Routes.login.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signup.path,
        name: Routes.signup.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(
          child: SignupScreen(),
        ),
      ),
      GoRoute(
        path: Routes.home.path,
        name: Routes.home.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(
          child: HomeScreen(),
        ),
      ),
    ],
    initialLocation: Routes.root.path,
    routerNeglect: true,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) async {
      final bool isWelcomePage = state.matchedLocation == Routes.root.path;
      final bool isLoginPage = state.matchedLocation == Routes.login.path;
      final bool isSignupPage = state.matchedLocation == Routes.signup.path;
      
      final User? user = FirebaseAuth.instance.currentUser;
      final bool isLoggedIn = user != null;

      // Jeśli użytkownik jest zalogowany, a próbuje wejść na Welcome, Login lub Signup -> przekieruj na Home
      if (isLoggedIn && (isWelcomePage || isLoginPage || isSignupPage)) {
        return Routes.home.path;
      }

      // Jeśli użytkownik NIE jest zalogowany, a próbuje wejść na Home -> przekieruj na Welcome/Login
      if (!isLoggedIn && state.matchedLocation == Routes.home.path) {
        return Routes.root.path;
      }

      return null; // Brak przekierowania
    },
  );

  static GoRouter get gorouter => router;
}