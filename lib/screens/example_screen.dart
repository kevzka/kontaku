import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../authentication/bloc/authentication.dart';
import '../authentication/event-state/authentication-event-state.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      listener: (context, state) {},
      child: Scaffold(body: Column(
        children: [
          Text("Example Screen"),
          ElevatedButton(onPressed: () {
            context.read<AuthenticationBloc>().add(getCurrentUser());
          }, child: Text("getCurrentUser"))
        ],
      )),
    );
  }
}
