class NumberModel {
  final String name;
  final String number;
  final String? email;
  final String? notes;
  final String? profilePath;
  final String uid;
  final String? uidNumber;

  const NumberModel({
    required this.name,
    required this.number,
    this.profilePath,
    required this.uid,
    this.uidNumber,
    this.email,
    this.notes,
  });
}

class AccountModel{
    final String username;
    final String uid;
    final String imageProfile;
    final String phoneNumber;
  const AccountModel({
    required this.username,
    required this.uid,
    required this.imageProfile,
    required this.phoneNumber,
  });
}
