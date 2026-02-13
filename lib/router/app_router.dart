import 'package:go_router/go_router.dart';
import 'package:kontaku/screens/SplashScreen.dart';
import 'package:kontaku/screens/ContactListScreen.dart';
import 'package:kontaku/screens/OnBoardingScreen.dart';
import 'package:kontaku/screens/login_screen.dart';
import 'package:kontaku/screens/register_screen.dart';
import 'package:kontaku/screens/register_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String contactList = '/contact-list';
  static const String onBoarding = '/onboarding';
  static const String loginScreen = '/loginScreen';
  static const String registerScreen = '/registerScreen';

  static final GoRouter router = GoRouter(
    initialLocation: loginScreen,
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
    ],
  );
}
