import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/camps/camps_screen.dart';
import '../../features/compatibility/compatibility_screen.dart';
import '../../features/donors/presentation/nearby_screen.dart';
import '../../features/eligibility/eligibility_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/requests/presentation/request_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../widgets/main_shell.dart';

/// Tells go_router to re-run `redirect` whenever login state changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

const _authPages = ['/', '/login', '/register'];
// Pages a logged-out visitor may open (proposal: visitors browse without login).
const _publicPages = [..._authPages, '/camps', '/eligibility', '/compatibility', '/blog'];

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(FirebaseAuth.instance.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      if (loggedIn && _authPages.contains(loc)) return '/home';
      if (!loggedIn && !_publicPages.contains(loc)) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/eligibility', builder: (_, _) => const EligibilityScreen()),
      GoRoute(path: '/compatibility', builder: (_, _) => const CompatibilityScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/nearby', builder: (_, _) => const NearbyScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/request', builder: (_, _) => const RequestScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/camps', builder: (_, _) => const CampsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});