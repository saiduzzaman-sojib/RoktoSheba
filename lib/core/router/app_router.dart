import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roktosheba/features/legal/hospitals/hospital_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/blog/blog_detail_screen.dart';
import '../../features/blog/blog_screen.dart';
import '../../features/camps/camps_screen.dart';
import '../../features/compatibility/compatibility_screen.dart';
import '../../features/donors/presentation/donor_detail_screen.dart';
import '../../features/donors/presentation/nearby_screen.dart';
import '../../features/eligibility/eligibility_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/legal/consent.dart';
import '../../features/legal/terms_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/requests/presentation/request_screen.dart';
import '../../features/requests/presentation/request_status_screen.dart';
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
const _publicPages = [..._authPages, '/camps', '/eligibility', '/compatibility', '/terms-view'];

bool _isPublic(String loc) => _publicPages.contains(loc) || loc.startsWith('/blog');

Map<String, String>? _extraMap(Object? e) =>
    e is Map ? e.map((k, v) => MapEntry('$k', '$v')) : null;

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(FirebaseAuth.instance.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([refresh, termsAccepted]),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!termsAccepted.value) {
        return loc == '/terms' ? null : '/terms';
      }
      if (loc == '/terms') return '/';
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      if (loggedIn && _authPages.contains(loc)) return '/home';
      if (!loggedIn && !_isPublic(loc)) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/terms', builder: (_, _) => const TermsScreen()),
      GoRoute(path: '/terms-view', builder: (_, _) => const TermsScreen(readOnly: true)),
      GoRoute(path: '/hospitals', builder: (_, __) => const HospitalScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/eligibility', builder: (_, _) => const EligibilityScreen()),
      GoRoute(path: '/compatibility', builder: (_, _) => const CompatibilityScreen()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
      GoRoute(path: '/blog', builder: (_, _) => const BlogScreen()),
      GoRoute(
        path: '/blog/:id',
        builder: (_, state) => BlogDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/donor/:uid',
        builder: (_, state) => DonorDetailScreen(uid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: '/request/:id',
        builder: (_, state) => RequestStatusScreen(id: state.pathParameters['id']!),
      ),
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
            GoRoute(
              path: '/request',
              builder: (_, state) => RequestScreen(extra: _extraMap(state.extra)),
            ),
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