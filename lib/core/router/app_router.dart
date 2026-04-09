import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:kontaku/features/add-contact-screen/ui/add-contact-screen.dart';
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
import '../../features/chat-screen/ui/chat-screen.dart';

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

  static const String splash = '/splash';
  static const String mainNavigation = '/mainNavigation';
  static const String onBoarding = '/onboarding';
  static const String loginScreen = '/loginScreen';
  static const String registerScreen = '/registerScreen';
  static const String exampleScreen = '/exampleScreen';
  static const String contactindividuscreen = "/contactIndividuScreen";
  static const String chatScreen = "/chatScreen";
  static const String addContactScreen = "/addContactScreen";

  late final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(authenticationBloc.stream),
    redirect: (context, state) {
      final authState = authenticationBloc.state;
      final isLoggedIn = authState is Authenticated;
      final isOnSplash = state.matchedLocation == splash;
      final isOnOnboarding = state.matchedLocation == onBoarding;
      final isLoggingIn = state.matchedLocation == loginScreen;
      final isRegistering = state.matchedLocation == registerScreen;
      final isAuthRoute = isLoggingIn || isRegistering;

      // Allow splash screen to show first
      if (isOnSplash) {
        return null; // Stay on splash, let it complete animation
      }

      // Allow login screen to handle its own navigation after snackbar
      if (isLoggingIn) {
        return null; // Let login screen handle navigation
      }

      // Allow register screen to handle its own logic
      if (isRegistering) {
        return null; // Let register screen handle navigation
      }

      // If not logged in and not on auth routes, redirect to onboarding
      if (!isLoggedIn && !isAuthRoute && !isOnOnboarding) {
        return onBoarding;
      }

      // If logged in and on onboarding, go to main navigation
      if (isLoggedIn && isOnOnboarding) {
        return mainNavigation;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(circleSize: 100),
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
      // GoRoute(
      //   path: chatScreen,
      //   name: 'chatScreen',
      //   builder: (context, state) => const ChatScreen(),
      // ),
      GoRoute(
        path: '/chatScreen/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatScreen(hisId: id);
        },
      ),
      GoRoute(
        path: addContactScreen,
        name: 'addContactScreen',

        builder: (context, state) {
          final numberPhone =
              state.extra as String; // Cast the extra object back to int
          return AddContactScreen(numberPhone: numberPhone);
        },
      ),
      GoRoute(
        path: exampleScreen,
        name: 'exampleScreen',
        builder: (context, state) => const ExampleScreen(),
      ),
    ],
  );
}
