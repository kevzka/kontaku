import 'package:flutter/material.dart';
import 'package:kontaku/core/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthenticationBloc authBloc = AuthenticationBloc()
    ..add(AuthenticationStatusChecked());
  late final AppRouter _appRouter = AppRouter(authBloc);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) => authBloc,
      child: ValueListenableBuilder<bool>(
        valueListenable: Kontaku.darkModeNotifier,
        builder: (context, isDarkMode, _) {
          return MaterialApp.router(
            title: 'Kontaku',
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFFBB58),
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFFBB58),
                brightness: Brightness.dark,
              ),
            ),
            routerConfig: _appRouter.router,
          );
  }),
      );
  }
}
