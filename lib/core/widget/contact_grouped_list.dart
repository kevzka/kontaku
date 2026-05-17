import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/features/home-screen/data/func.dart';

class ContactGroupedList extends StatelessWidget {
  const ContactGroupedList({
    required this.contacts,
    required this.sectionColor,
    this.enableSelection = false,
    this.selectedContactNumbers = const <String>{},
    this.onToggleContactSelection,
    this.onContactDetailsChanged,
    this.sortBy = "alphabet",
    this.categoriesRows = const <Map<String, Object>>[],
    super.key,
  });

  final List<NumberModel> contacts;
  final Color sectionColor;
  final bool enableSelection;
  final Set<String> selectedContactNumbers;
  final ValueChanged<NumberModel>? onToggleContactSelection;
  final VoidCallback? onContactDetailsChanged;
  final String sortBy;
  final List<Map<String, Object>> categoriesRows;

  List<Map<String, Object>> _buildGroupedRows() {
    final rows = <Map<String, Object>>[];
    String? currentSection;

    // `contacts` is expected to be pre-sorted by caller for large lists.
    for (final contact in contacts) {
      final name = contact.name;
      final section = name.isEmpty ? '#' : name[0].toUpperCase();

      if (section != currentSection) {
        rows.add({'type': 'section', 'value': section});
        currentSection = section;
      }

      rows.add({'type': 'contact', 'value': contact});
    }

    return rows;
  }

  Widget _buildAvatar(BuildContext context, NumberModel contact) {
    final bool isSelected = selectedContactNumbers.contains(contact.number);
    final profilePath = contact.profilePath;
    final name = contact.name;
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    if (profilePath != null && profilePath.isNotEmpty) {
      ImageProvider imageProvider = AssetImage(profilePath);
      if (profilePath.startsWith('http')) {
        // debugPrint(
        //   'Loading network image for contact ${contact.name} from $profilePath',
        // );
        imageProvider = NetworkImage(profilePath);
      }

      return Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: enableSelection
              ? () => onToggleContactSelection?.call(contact)
              : () async {
                  final result = await context.push(
                    '/contactDetailsScreen',
                    extra: contact,
                  );
                  if (result == true) {
                    print("contact details changed, refreshing...");
                    onContactDetailsChanged?.call();
                  }
                },
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          radius: 24,
          splashColor: const Color(0x1A8B6E3A),
          highlightColor: const Color(0x148B6E3A),
          child: CircleAvatar(
            radius: 22,
            backgroundImage: imageProvider,
            foregroundColor: isSelected ? Color(Kontaku.colors[0]) : null,
            child: isSelected
                ? Icon(Icons.check_circle, color: Color(Kontaku.colors[0]))
                : null,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: enableSelection
            ? () => onToggleContactSelection?.call(contact)
            : () async {
                final result = await context.push(
                  '/contactDetailsScreen',
                  extra: contact,
                );
                if (result == true) {
                  print("contact details changed, refreshing...");
                  onContactDetailsChanged?.call();
                }
              },
        containedInkWell: true,
        highlightShape: BoxShape.circle,
        radius: 24,
        splashColor: const Color(0x1A8B6E3A),
        highlightColor: const Color(0x148B6E3A),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF8B6E3A),
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedRows = (sortBy == "alphabet")
        ? _buildGroupedRows()
        : categoriesRows;

    //tanpa section"
    //tanpa section - hanya tampilkan by recency (paling baru di atas)
    if (sortBy == "NotSorted") {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        cacheExtent: 800,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _buildAvatar(context, contact),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      splashColor: const Color(0x1A8B6E3A),
                      highlightColor: const Color(0x148B6E3A),
                      onTap: () async {
                        if (enableSelection) {
                          onToggleContactSelection?.call(contact);
                          return;
                        }

                        final String? targetUserUid =
                            await findUserUidByPhoneNumber(
                              number: contact.number,
                            );
                        debugPrint("targetUserUid: ${contact.uid}");
                        if (targetUserUid != null) {
                          context.push(
                            '/chatScreen/$targetUserUid',
                            extra: contact,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Akun dengan nomor ini tidak ditemukan.",
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                contact.name,
                                style: TextStyle(
                                  color: Color(Kontaku.colors[0]),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.05,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (enableSelection)
                              Icon(
                                selectedContactNumbers.contains(contact.number)
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 20,
                                color:
                                    selectedContactNumbers.contains(
                                      contact.number,
                                    )
                                    ? Color(Kontaku.colors[0])
                                    : const Color(0xFF7A7A7A),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      cacheExtent: 800,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final row = groupedRows[index];

        if (row['type'] == 'section') {
          final section = row['value'] as String;

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
            child: Row(
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    color: sectionColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                  child: Text(
                    section,
                    style: TextStyle(
                      color: sectionColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Container(height: 2, color: sectionColor)),
              ],
            ),
          );
        }

        final contact = row['value'] as NumberModel;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _buildAvatar(context, contact),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: const Color(0x1A8B6E3A),
                    highlightColor: const Color(0x148B6E3A),
                    onTap: () async {
                      if (enableSelection) {
                        onToggleContactSelection?.call(contact);
                        return;
                      }

                      final String? targetUserUid =
                          await findUserUidByPhoneNumber(
                            number: contact.number,
                          );
                      print("targetUserUid: $targetUserUid");
                      if (targetUserUid != null) {
                        context.push(
                          '/chatScreen/$targetUserUid',
                          extra: contact,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Akun dengan nomor ini tidak ditemukan.",
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.name,
                              style: TextStyle(
                                // color: Color(0xFF1C2026),
                                color: Color(Kontaku.colors[0]),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.05,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (enableSelection)
                            Icon(
                              selectedContactNumbers.contains(contact.number)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color:
                                  selectedContactNumbers.contains(
                                    contact.number,
                                  )
                                  ? Color(Kontaku.colors[0])
                                  : const Color(0xFF7A7A7A),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: groupedRows.length,
    );
  }
}
