class NumberModel {
  final String name;
  final String number;
  final String? email;
  final String? notes;
  final String? profilePath;
  final String? uid;
  final String? uidNumber;

  const NumberModel({
    required this.name,
    required this.number,
    this.profilePath,
    this.uid,
    this.uidNumber,
    this.email,
    this.notes,
  });
}
