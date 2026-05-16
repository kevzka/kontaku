import 'package:kontaku/core/dummies/number-dummy.dart';

void deleteDummyContact(String number) {
  final normalizedNumber = number.trim();
  if (normalizedNumber.isEmpty) {
    return;
  }

  DummyData.contacts.removeWhere(
    (contact) => contact.number.trim() == normalizedNumber,
  );
}