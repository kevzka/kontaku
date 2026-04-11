import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/features/authentication/bloc/authentication.dart';
import 'package:kontaku/features/home-screen/data/dummy.dart';
import 'package:kontaku/features/home-screen/data/func.dart';
// import '../../contact-list-screen/ui/contact-list-screen.dart';
import 'package:kontaku/core/widget/search_contacts_panel.dart';
import 'package:kontaku/core/widget/contact_grouped_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<NumberModel> dummyContacts = List<NumberModel>.from(
    DummyData.contacts,
  );
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNumberInAccount();
  }

  Future<void> _loadAllNumberInAccount() async {
    final accountNumbers = await fetchCurrentUserContactNumbers(
      context.read<AuthenticationBloc>(),
    );
    if (!mounted) {
      return;
    }

    setState(() {
      final mergedContacts = mergeContactsWithCloudNumbers(
        dummyContacts,
        accountNumbers,
      )..sort((a, b) => a.name.compareTo(b.name));

      dummyContacts
        ..clear()
        ..addAll(mergedContacts);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Kontaku.vw(100, context),
      height: Kontaku.vh(100, context),
      color: Color(Kontaku.colors[1]),
      child: Stack(
        children: [
          Container(
            width: Kontaku.vw(100, context) - 80,
            height: Kontaku.vh(100, context),
            decoration: BoxDecoration(
              color: Color(Kontaku.colors[2]),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(Kontaku.vw(100, context) * 0.35),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 128,
            child: Center(
              child: Container(
                width: Kontaku.vw(80, context),
                height: Kontaku.vh(70, context),
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ContactGroupedList(
                        contacts: dummyContacts,
                        sectionColor: Color(Kontaku.colors[0]),
                      ),
              ),
            ),
          ),
          //make plus button for adding number of contact
          Positioned(
            bottom: Kontaku.vh(12, context),
            right: 50,
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Color(Kontaku.colors[1]),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 4),
              ),
              onPressed: () {
                // addContactNumberForCurrentUser(
                //   authenticationBloc: context.read<AuthenticationBloc>(),
                //   name: "kevin2",
                //   number: "622234567890",
                // );
                context.go('/addGroupScreen');
              },
              child: const Icon(
                Icons.add,
                color: Color(Kontaku.dark),
                size: 30,
              ),
            ),
          ),
          Positioned(
            child: ElevatedButton(
              onPressed: () {
                print("delete all data firestore in document numberDetails");
                deleteAllDataInNumberDetails(
                  context.read<AuthenticationBloc>(),
                );
              },
              child: Text(
                "delete all data firestore in document numberDetails",
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 40,
            child: const SearchContactsPanel(),
          ),
        ],
      ),
    );
  }
}


