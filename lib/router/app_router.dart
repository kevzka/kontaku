import 'package:go_router/go_router.dart';
import 'package:kontaku/screens/SplashScreen.dart';
import 'package:kontaku/screens/ContactListScreen.dart';
import 'package:kontaku/screens/OnBoardingScreen.dart';

class AppRouter {
  static const String splash = '/';
  static const String contactList = '/contact-list';
  static const String onBoarding = '/onboarding';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
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
    ],
  );
}
