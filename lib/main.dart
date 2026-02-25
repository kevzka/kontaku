import 'package:flutter/material.dart';
import 'package:kontaku/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:kontaku/authentication/bloc/authentication.dart';
import 'package:kontaku/authentication/event-state/authentication-event-state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
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
      child: MaterialApp.router(
        title: 'Kontaku',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
