import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:kontaku/splash-screen/ui/SplashScreen.dart';
import 'package:kontaku/contact-list-screen/ui/ContactListScreen.dart';
import 'package:kontaku/on-boarding-screen/ui/OnBoardingScreen.dart';
import 'package:kontaku/authentication/login/ui/login_screen.dart';
import 'package:kontaku/authentication/register/ui/register_screen.dart';
import 'package:kontaku/screens/example_screen.dart';
import 'package:kontaku/contact-details/ui/contact_individu_screen.dart';
import 'package:kontaku/authentication/bloc/authentication.dart';
import 'package:kontaku/authentication/event-state/authentication-event-state.dart';
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
  static const String contactList = '/contact-list';
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
        return exampleScreen;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(circleSize: 100),
        // builder: (context, state) => const ContactListScreen(),
      ),
      GoRoute(
        path: contactList,
        name: 'contactList',
        builder: (context, state) => const ContactListScreen(),
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
