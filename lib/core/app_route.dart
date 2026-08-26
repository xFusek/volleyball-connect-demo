import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../features/matches/presentation/screens/create_match_screen.dart';
import '../features/matches/presentation/screens/match_details_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

enum Routes {
  root("/"),
  login("/login"),
  signup("/signup"),
  home("/home"),
  notifications("/notifications"),
  createMatch("/create-match"),
  matchDetails("/match-details/:id");

  const Routes(this.path);
  final String path;
}

// Stream z Firebase w Listenable dla GoRoutera
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}

class AppRoute {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: Routes.root.path,
        name: Routes.root.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(child: WelcomeScreen()),
      ),
      GoRoute(
        path: Routes.login.path,
        name: Routes.login.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: Routes.signup.path,
        name: Routes.signup.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            NoTransitionPage(child: SignupScreen()),
      ),
      GoRoute(
        path: Routes.home.path,
        name: Routes.home.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: Routes.notifications.path,
        name: Routes.notifications.name,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.createMatch.path,
        name: Routes.createMatch.name,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage(child: CreateMatchScreen()),
      ),
      GoRoute(
        path: '/match-details/:id',
        name: Routes.matchDetails.name,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final matchId = state.pathParameters['id'] ?? '';
          return NoTransitionPage(child: MatchDetailsScreen(matchId: matchId));
        },
      ),
    ],
    initialLocation: Routes.root.path,
    routerNeglect: true,
    debugLogDiagnostics: kDebugMode,
    // Kluczowa zmiana: router odświeża się automatycznie, gdy zmieni się stan auth w Firebase
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (BuildContext context, GoRouterState state) {
      final bool isWelcomePage = state.matchedLocation == Routes.root.path;
      final bool isLoginPage = state.matchedLocation == Routes.login.path;
      final bool isSignupPage = state.matchedLocation == Routes.signup.path;

      final User? user = FirebaseAuth.instance.currentUser;
      final bool isLoggedIn = user != null;

      // Jeśli user jest zalogowany, a próbuje wejść na ekrany autoryzacji -> wyślij na home
      if (isLoggedIn && (isWelcomePage || isLoginPage || isSignupPage)) {
        return Routes.home.path;
      }

      // Jeśli user NIE jest zalogowany, a próbuje wejść na home -> wyślij na welcome
      if (!isLoggedIn && state.matchedLocation == Routes.home.path) {
        return Routes.root.path;
      }

      return null;
    },
  );

  static GoRouter get gorouter => router;
}
