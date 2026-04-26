import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/core/dummies/number-dummy.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/home-screen/data/func.dart';

class SearchContactsPanel extends StatefulWidget {
  const SearchContactsPanel({super.key});

  @override
  State<SearchContactsPanel> createState() => SearchContactsPanelState();
}

class SearchContactsPanelState extends State<SearchContactsPanel> {
  static const Duration _panelAnimationDuration = Duration(milliseconds: 500);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  String _lastQuery = '';

  // final List<Map<String, String>> _dummyContacts = [
  //   {'name': 'Abc', 'number': '081234567890', 'email': 'abc@mail.com'},
  //   {'name': 'Budi', 'number': '082233445566', 'email': 'budi@mail.com'},
  //   {'name': 'Citra', 'number': '083355577799', 'email': 'citra@mail.com'},
  //   {'name': 'Doni', 'number': '085712345678', 'email': 'doni@mail.com'},
  //   {'name': 'Eka', 'number': '087788990011', 'email': 'eka@mail.com'},
  // ];
  final List<NumberModel> _dummyContacts = List<NumberModel>.from(
    DummyData.contacts,
  );
  final List<NumberModel> _chatParticipants = <NumberModel>[];
  bool _isLoading = true;

  final List<_IndexedContact> _indexedContacts = [];
  late List<NumberModel> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _filteredContacts = List.from(_dummyContacts);
    _rebuildSearchIndex();
    _loadAllHomeData();

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  Future<void> _loadAllHomeData() async {
    try {
      final authBloc = context.read<AuthenticationBloc>();
      final results = await Future.wait([
        fetchCurrentUserContactNumbers(authBloc),
        fetchAllChatParticipants(authenticationBloc: authBloc),
      ]);

      final accountNumbers = results[0] as List<NumberModel>;
      final chatParticipants = results[1] as List<NumberModel>;

      final mergedContacts = mergeContactsWithCloudNumbers(
        _dummyContacts,
        accountNumbers,
      )..sort((a, b) => a.name.compareTo(b.name));

      if (!mounted) {
        return;
      }

      setState(() {
        _dummyContacts
          ..clear()
          ..addAll(mergedContacts);
        _chatParticipants
          ..clear()
          ..addAll(chatParticipants);
        _rebuildSearchIndex();
        _isLoading = false;
      });

      _applySearch();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _rebuildSearchIndex() {
    _indexedContacts.clear();
    for (final contact in _dummyContacts) {
      final name = contact.name.toLowerCase();
      final number = contact.number.toLowerCase();
      final email = (contact.email ?? '').toLowerCase();
      _indexedContacts.add(
        _IndexedContact(data: contact, searchBlob: '$name|$number|$email'),
      );
    }

    _filteredContacts = List.from(_dummyContacts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 180), _applySearch);
  }

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _lastQuery) {
      return;
    }
    _lastQuery = query;

    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_dummyContacts);
      } else {
        final List<NumberModel> result = [];
        for (final contact in _indexedContacts) {
          if (contact.searchBlob.contains(query)) {
            result.add(contact.data);
          }
        }
        _filteredContacts = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(mainAxisSize: MainAxisSize.min, children: [_searchField()]),
    );
  }

  Widget _searchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2126),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _searchFocusNode.requestFocus();
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          AnimatedSwitcher(
            duration: _panelAnimationDuration,
            reverseDuration: _panelAnimationDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );

              return FadeTransition(
                opacity: curved,
                child: SizeTransition(
                  sizeFactor: curved,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: _searchFocusNode.hasFocus
                ? Container(
                    key: const ValueKey('contacts-open'),
                    margin: const EdgeInsets.only(top: 4),
                    child: _contactList(),
                  )
                : const SizedBox(key: ValueKey('contacts-closed')),
          ),
        ],
      ),
    );
  }

  Widget _contactList() {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final double listHeight = (_filteredContacts.length * 72.0).clamp(
      72.0,
      250.0,
    );

    return Container(
      height: listHeight,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2126),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _filteredContacts.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Kontak tidak ditemukan',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemExtent: 68,
              cacheExtent: 320,
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                final name = contact.name ?? '-';
                final number = contact.number ?? '-';

                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    number,
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
    );
  }
}

class _IndexedContact {
  const _IndexedContact({required this.data, required this.searchBlob});

  final NumberModel data;
  final String searchBlob;
}
