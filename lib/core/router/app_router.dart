import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:kontaku/features/splash-screen/ui/SplashScreen.dart';
import 'package:kontaku/features/main-navigation-screen/ui/main-navigation-screen.dart';
import 'package:kontaku/features/on-boarding-screen/ui/OnBoardingScreen.dart';
import 'package:kontaku/features/authentication/login/ui/login_screen.dart';
import 'package:kontaku/features/authentication/register/ui/register_screen.dart';
import 'package:kontaku/features/screens/example_screen.dart';
import 'package:kontaku/features/contact-details/ui/contact_individu_screen.dart';
import 'package:kontaku/features/authentication/bloc/authentication.dart';
import 'package:kontaku/features/authentication/event-state/authentication-event-state.dart';
import 'package:flutter/foundation.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthenticationBloc authenticationBloc;

  AppRouter(this.authenticationBloc);

  static const String splash = '/';
  static const String mainNavigation = '/mainNavigation';
  static const String onBoarding = '/onboarding';
  static const String loginScreen = '/loginScreen';
  static const String registerScreen = '/registerScreen';
  static const String exampleScreen = '/exampleScreen';
  static const String contactindividuscreen = "/contactIndividuScreen";

  late final GoRouter router = GoRouter(
    initialLocation: loginScreen,
    refreshListenable: GoRouterRefreshStream(authenticationBloc.stream),
    redirect: (context, state) {
      final authState = authenticationBloc.state;
      final isLoggedIn = authState is Authenticated;
      final isLoggingIn = state.matchedLocation == loginScreen;
      final isRegistering = state.matchedLocation == registerScreen;
      final isAuthRoute = isLoggingIn || isRegistering;

      if (!isLoggedIn && !isAuthRoute) {
        return loginScreen;
      }

      if (isLoggedIn && isAuthRoute) {
        return mainNavigation;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(circleSize: 100),
        // builder: (context, state) => const mainNavigationScreen(),
      ),
      GoRoute(
        path: mainNavigation,
        name: 'mainNavigation',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: onBoarding,
        name: 'onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
      GoRoute(
        path: loginScreen,
        name: 'loginScreen',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerScreen,
        name: 'registerScreen',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: contactindividuscreen,
        name: 'contactIndividuScreen',
        builder: (context, state) => const ContactIndividuScreen(),
      ),
      GoRoute(
        path: exampleScreen,
        name: 'exampleScreen',
        builder: (context, state) => const ExampleScreen(),
      ),
    ],
  );
}
