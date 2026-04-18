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

  factory NumberModel.fromFirestoreMap(
    Map<String, dynamic> data, {
    required String fallbackUid,
  }) {
    return NumberModel(
      name: data['name'] as String? ?? '',
      number: data['number'] as String? ?? '',
      profilePath: data['profilePath'] as String?,
      uid: data['uid'] as String? ?? fallbackUid,
      uidNumber: data['uidNumber'] as String?,
      email: data['email'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'number': number,
      'profilePath': profilePath,
      'uid': uid,
      'uidNumber': uidNumber,
      'email': email,
      'notes': notes,
    };
  }
}
