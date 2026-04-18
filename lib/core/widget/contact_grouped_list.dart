import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/features/home-screen/data/func.dart';

class ContactGroupedList extends StatelessWidget {
  const ContactGroupedList({
    required this.contacts,
    required this.sectionColor,
    this.enableSelection = false,
    this.selectedContactNumbers = const <String>{},
    this.onToggleContactSelection,
    super.key,
  });

  final List<NumberModel> contacts;
  final Color sectionColor;
  final bool enableSelection;
  final Set<String> selectedContactNumbers;
  final ValueChanged<NumberModel>? onToggleContactSelection;

  List<Map<String, Object>> _buildGroupedRows() {
    final sortedContacts = [...contacts]
      ..sort((a, b) => a.name.compareTo(b.name));

    final rows = <Map<String, Object>>[];
    String? currentSection;

    for (final contact in sortedContacts) {
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
        imageProvider = NetworkImage(profilePath);
      }

      return Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: enableSelection
              ? () => onToggleContactSelection?.call(contact)
              : () => context.go('/contactDetailsScreen', extra: contact),
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          radius: 24,
          splashColor: const Color(0x1A8B6E3A),
          highlightColor: const Color(0x148B6E3A),
          child: CircleAvatar(
            radius: 22,
            backgroundImage: imageProvider,
            foregroundColor: isSelected ? const Color(0xFF1C2026) : null,
            child: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFF1C2026))
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
            : () => context.go('/contactDetailsScreen', extra: contact),
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
    final groupedRows = _buildGroupedRows();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final row = groupedRows[index];

        if (row['type'] == 'section') {
          final section = row['value'] as String;

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
            child: Row(
              children: [
                Text(
                  section,
                  style: TextStyle(
                    color: sectionColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
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
                      if (targetUserUid != null) {
                        context.go('/chatScreen/$targetUserUid');
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
                              style: const TextStyle(
                                color: Color(0xFF1C2026),
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
                                  ? const Color(0xFF1C2026)
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
