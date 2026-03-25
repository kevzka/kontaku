import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../authentication/bloc/authentication.dart';
import '../authentication/event-state/authentication-event-state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    // return BlocListener<AuthenticationBloc, AuthenticationState>(
    //   listener: (context, state) {},
    //   child: Scaffold(body: Column(
    //     children: [
    //       Text("Example Screen"),
    //       ElevatedButton(onPressed: () {
    //         context.read<AuthenticationBloc>().add(getCurrentUser());
    //       }, child: Text("getCurrentUser"))
    //     ],
    //   )),
    // );
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              Text("Example Screen"),
              ElevatedButton(
                onPressed: () {
                  // context.read<AuthenticationBloc>().add(getCurrentUser());
                  firestoreAdd(state is Authenticated ? state.user.uid : "not authenticated");
                  fireStoreRead();
                },
                child: Text("current user id is ${state is Authenticated ? state.user.uid : "not authenticated"}"),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> fireStoreRead() async {
    final db = FirebaseFirestore.instance;
    try{
    await db.collection("category").where("uid", isEqualTo: "1234567890qwertyuiop").get().then((event) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    },
    onError: (e) => print("Error fetching data: $e")
    );
    }catch(e){
      print("Error fetching data: $e");
    }
  }

  Future<void> firestoreAdd(String uid) async {
    try{
    final db = FirebaseFirestore.instance;
    db
    .collection("category")
    .doc()
    .set({
      "uid": uid,
      "number": "081234567890",
      "category": "teman",
    })
    .onError((e, _) => print("Error writing document: $e"));
    print("Document successfully written!");
    }catch(e){
      print("Error writing document: $e");
    }
  }
