import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/utils/utils.dart';

Color borderColor = Color.fromARGB(255, 255, 230, 194);

class Contactlistscreen2 extends StatefulWidget {
  const Contactlistscreen2({super.key});

  @override
  State<Contactlistscreen2> createState() => _Contactlistscreen2State();
}

class _Contactlistscreen2State extends State<Contactlistscreen2> {
  TextEditingController _numberPhoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _numberPhoneController.text = "081234567890";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Kontaku.vw(100, context),
      height: Kontaku.vh(100, context),
      color: Color(Kontaku.colors[3]),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 130,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: Kontaku.vw(72, context),
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1114),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          child: Expanded(
                            child: TextField(
                              controller: _numberPhoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                height: 1,
                              ),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _numberPhoneController.text = _numberPhoneController
                                .text
                                .substring(
                                  0,
                                  _numberPhoneController.text.length - 1,
                                );
                            print('Delete button pressed');
                          },
                          icon: const Icon(
                            Icons.backspace,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: Kontaku.vw(50, context),
                    child: GridView(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      children: [
                        inputNumber("1"),
                        inputNumber("2"),
                        inputNumber("3"),
                        inputNumber("4"),
                        inputNumber("5"),
                        inputNumber("6"),
                        inputNumber("7"),
                        inputNumber("8"),
                        inputNumber("9"),
                        inputNumber("*"),
                        inputNumber("0"),
                        inputNumber("#"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 94,
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 30),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 84 * 2,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Color(Kontaku.colors[1]),
                        border: Border.all(
                          color: borderColor, // Border color
                          width: 4.0, // Border width
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print('Call button pressed');
                              },
                              child: SizedBox(
                                child: Icon(
                                  Icons.phone,
                                  color: Color(Kontaku.colors[3]),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print('Call button pressed');
                              },
                              child: SizedBox(
                                child: Icon(
                                  Icons.phone,
                                  color: Color(Kontaku.colors[3]),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -30,
                      left: 0,
                      right: 0,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Color(Kontaku.colors[1]),
                        shape: const CircleBorder(
                          side: BorderSide(color: Colors.white, width: 4),
                        ),
                        onPressed: () {
                          addContact(context, number: _numberPhoneController.text);
                          print('Add contact button pressed');
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Container inputNumber(String number) {
    const double buttonSize = 64;
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: ElevatedButton(
          onPressed: () {
            print('Number $number pressed');
            _numberPhoneController.text += number;
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Color(Kontaku.colors[1]),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            side: BorderSide(color: borderColor, width: 4.0),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchContactsPanel extends StatefulWidget {
  const SearchContactsPanel();

  @override
  State<SearchContactsPanel> createState() => SearchContactsPanelState();
}

class SearchContactsPanelState extends State<SearchContactsPanel> {
  static const Duration _panelAnimationDuration = Duration(milliseconds: 500);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  String _lastQuery = '';

  final List<Map<String, String>> _dummyContacts = [
    {'name': 'Abc', 'number': '081234567890', 'email': 'abc@mail.com'},
    {'name': 'Budi', 'number': '082233445566', 'email': 'budi@mail.com'},
    {'name': 'Citra', 'number': '083355577799', 'email': 'citra@mail.com'},
    {'name': 'Doni', 'number': '085712345678', 'email': 'doni@mail.com'},
    {'name': 'Eka', 'number': '087788990011', 'email': 'eka@mail.com'},
  ];

  final List<_IndexedContact> _indexedContacts = [];
  late List<Map<String, String>> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _filteredContacts = List.from(_dummyContacts);
    for (final contact in _dummyContacts) {
      final name = (contact['name'] ?? '').toLowerCase();
      final number = (contact['number'] ?? '').toLowerCase();
      final email = (contact['email'] ?? '').toLowerCase();
      _indexedContacts.add(
        _IndexedContact(data: contact, searchBlob: '$name|$number|$email'),
      );
    }

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
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
        final List<Map<String, String>> result = [];
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
    return Column(mainAxisSize: MainAxisSize.min, children: [_searchField()]);
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
                final name = contact['name'] ?? '-';
                final number = contact['number'] ?? '-';

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

  final Map<String, String> data;
  final String searchBlob;
}

void addContact(BuildContext context, {required String number}) {
  context.go('/addContactScreen', extra: number);
  print('Add contact $number button pressed');
}
